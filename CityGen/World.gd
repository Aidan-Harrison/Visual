extends Node3D;

# Core
@onready var chunk = preload("res://Chunk.tscn");
# Roads
@onready var r_mesh_1 = preload("res://Roads/CityGenRoadTile1.obj");

# Mega buildings
@onready var mB1 = preload("res://Assets/CityGen_MegaBuildingTest.obj");
@onready var mB2 = preload("res://Assets/CityGen_MegaBuildingTest.obj");

# Highways
@onready var highwayStraight = preload("res://Roads/CityGenHighway.obj");

# VFX
@onready var flyingCars = preload("res://VFX/Cars.tscn");

# Extra
@onready var treeMat  = preload("res://Extra/TreeMat.tres");
@onready var baseMat  = preload("res://Extra/BaseMat.tres");
@onready var buildMat = preload("res://Extra/BuildingMat.tres");
@onready var mBuildMat = preload("res://Extra/MegaBuildingMat.tres");

# Roads
@onready var road1 = preload("res://Roads/Road1.tscn");

# Below auto scales
	# Chunks per tile | W * H
var WIDTH : int = 4;
var HEIGHT : int = 4;

# === Storage ===
var roads = [
	[]
];
var m_buildings = []; # Stores mega building assets, MOVE TO GLOBAL!
var tiles = [];
var tileTypes = []; # Base type generation | Building, vegetation, body-of-water, etc.
var districts = []; # Building type generation
var vRays = [];
var vegetation = {}; # Index | LOD
var iVRayPos = []; # Initial positions of vegetation rays
var megaBuildings = [];
var b_chunks = []; # Building chunks
# === Generation ===
var vRayOffset : Vector3 = Vector3.ZERO;
var light_colors = [Color.RED, Color.BLANCHED_ALMOND, Color.DARK_ORANGE];
var vegStepSize : float = 225.0;
var roadOffset : Vector3 = Vector3(0.0, 7.0, 0.0); # Starts at centre of first tile
var rOffsetStart : Vector3 = roadOffset;
var chunkRotation : float = 0.0;
var testIndex : int = 1;

# Make so vegetation intially starts at xBounds/2, zBounds/2
# Make base tile generation uniform
	# 8 = 4x4
	# 16 = 8x8

# Sun rotation = -6.3, -82, 110.6

# Interface
	# === ROADS, LIGHTS, MEGA BUILDINGS ===
enum flag_indexes{ROADS, LIGHTS, MEGABUILD, HIGHWAY, VEGETATION, RIVER, CARS}; # Remove lights generation
@export var generation_flags = [false,false,true,false,true,false,false]; # Make UI only, not export
@export var numberOfTiles : int = 72; # Max: 256 with mesh visible diabled on generation!
@export var uniform : bool = true;
@export var highwaySectionLength : int = 3;
@export var numOfHighways : int = 1; # Height is self solving
# Interface | Debugging
@export var stats : bool = false;
@export var segmentDebug : bool = false;

func _ready() -> void:
	if(generation_flags[flag_indexes.VEGETATION]):
		set_physics_process(true); 
		for _i in range(0, numberOfTiles): # Vegetation rays, used for tree generation
			var vegRay : RayCast3D = RayCast3D.new();
			add_child(vegRay);
			vRays.append(vegRay);
			vegRay.target_position.y = -1000.0;
			#vegRay.debug_shape_thickness = 5;
			#vegRay.debug_shape_custom_color = Color.RED;
	else:
		set_physics_process(false);
	# Change, global script?
	m_buildings.append(mB1);
	m_buildings.append(mB2);
	get_viewport().debug_draw = 0;
	call_deferred("Tile");
	if(generation_flags[flag_indexes.HIGHWAY]):
		var height : float = 50.0;
		for _i in numOfHighways:
			Highway(height);
			height -= 100.0;
	set_physics_process(false);

func Tile() -> void:
	var posOffset : Vector2 = Vector2.ZERO;
	for i in numberOfTiles: # Fix this to be uniform!!!!!
		#if(generation_flags[flag_indexes.VEGETATION]): # !!!!MOVE!!!!!
			#vRays[i].position = Vector3(posOffset.x, 750.0, posOffset.y);
			#iVRayPos.append(vRays[i].position);
		tiles.append(Generate()); # Generate tile of chunks
		tiles[i].global_transform.origin = Vector3(posOffset.x, 0.0, posOffset.y);
		posOffset.x += GlobalSettings.chunkXBounds * WIDTH;
		if(posOffset.x >= GlobalSettings.chunkXBounds*WIDTH*10):
			posOffset.x = 0;
			posOffset.y += GlobalSettings.chunkZBounds * HEIGHT;
		#if(posOffset.x >= GlobalSettings.chunkXBounds*WIDTH*numberOfTiles*0.1): # FIX!!! Always make square
		#testIndex = i; # Ideally remove post world coord fix
			
func Highway(height : float) -> void: # === Highway Generation ===
	# Generate starting position
		# Improve/fix starting generation!
	var startingPos : Vector3 = Vector3(randi_range(GlobalSettings.chunkXBounds/2, GlobalSettings.chunkXBounds*WIDTH*2), height, randi_range(GlobalSettings.chunkZBounds/2, GlobalSettings.chunkZBounds*HEIGHT*2));
	var head : Vector3 = startingPos; # Position of road
	var validDirections = [true,true,true,true];
	var counter : int = 0;
	var direction : int = 1;
	for i in range(WIDTH*HEIGHT*numberOfTiles): #? -> *2
		if(!validDirections[0] && !validDirections[1] && !validDirections[2] && !validDirections[3]): # Cannot go anywhere
			break;
		var newHighwaySection : StaticBody3D = StaticBody3D.new();
		add_child(newHighwaySection); # Add to tile!
		var highwayMesh : MeshInstance3D = MeshInstance3D.new();
		newHighwaySection.add_child(highwayMesh);
		highwayMesh.mesh = highwayStraight;
		highwayMesh.set_surface_override_material(0, baseMat);
		var highwayCol : CollisionShape3D = CollisionShape3D.new();
		newHighwaySection.add_child(highwayCol);
		highwayMesh.scale *= GlobalSettings.chunkXBounds;
		highwayCol.scale *= GlobalSettings.chunkXBounds; #???
		newHighwaySection.position = head;
		# Check around head for collisions or bounds
		if(head.x - GlobalSettings.chunkXBounds <= 0.0): # X Bounds check
			validDirections[0] = false; # left is no longer valid
		if(head.x + GlobalSettings.chunkXBounds >= GlobalSettings.chunkXBounds*WIDTH*numberOfTiles): # Fix
			validDirections[1] = false;
		if(head.z - GlobalSettings.chunkZBounds <= 0.0):
			validDirections[2] = false;
		if(head.z + GlobalSettings.chunkZBounds >= GlobalSettings.chunkZBounds*HEIGHT*numberOfTiles): # Fix
			validDirections[3] = false;
		if(counter % highwaySectionLength == 0): # Only change direction every x amount of times
			counter = 0;
			direction = randi_range(0,3); # Highway pathing
			while(!validDirections[direction]):
				direction = randi_range(0,3);
		match(direction):
			0: 
				head.x -= GlobalSettings.chunkXBounds; # Left
				newHighwaySection.rotation.y = 1.57;
			1: 
				head.x += GlobalSettings.chunkXBounds; # Right
				newHighwaySection.rotation.y = 1.57;
			2: head.z -= GlobalSettings.chunkZBounds; # Up
			3: head.z += GlobalSettings.chunkZBounds; # Down
		counter += 1;
		validDirections = [true,true,true,true];

func MegaCull() -> void:
	for i in megaBuildings:
		#print("Building: ", i, "\tCollisions: ", i.get_overlapping_bodies());
		for j in i.get_overlapping_bodies():
			#print(j);
			if(j.is_in_group("Chunk")):
				if(i.position.distance_to(j.position) < GlobalSettings.chunkXBounds*2):
					j.queue_free();
				j.mesh.scale.y *= 2.5;
			elif(j.is_in_group("Mega")):
				print("Building: ", j)
				j.set_surface_override_material(0, treeMat);
				j.queue_free();
			elif(j.is_in_group("Tree")):
				if(i.position.distance_to(j.position) < GlobalSettings.chunkXBounds*2):
					j.queue_free();

func Generate() -> Node3D:
	# === Tile Generation ===
	var district = randi_range(0,3);
	districts.append(district); # Building districts
	tileTypes.append(randf_range(0.0, 1.0));
	var newTile : StaticBody3D = StaticBody3D.new(); # Stores EVERYTHING
	add_child(newTile);
	var newCol : CollisionShape3D = CollisionShape3D.new(); # Used for ray collision
	newTile.add_child(newCol);
	newCol.shape = BoxShape3D.new();
	newCol.shape.size = Vector3(GlobalSettings.chunkXBounds * WIDTH, 1.0, GlobalSettings.chunkZBounds * HEIGHT);
	newTile.add_to_group("Ground");
	for i in WIDTH: # Convert to single for loop?
		# === Light Generation === | Change!? | Remove?
		if(generation_flags[flag_indexes.LIGHTS]):
			var chance : float = randf_range(0.0, 1.0);
			if(chance > 0.9):
				var newLight : OmniLight3D = OmniLight3D.new();
				add_child(newLight);
				newLight.omni_range = 250;
				newLight.light_energy = 300.0;
				#newLight.light_color = light_colors[randi_range(0, light_colors.size()-1)];
				newLight.position = Vector3(randf_range(0.0, GlobalSettings.chunkXBounds*WIDTH*numberOfTiles), 0.0, randf_range(0.0, GlobalSettings.chunkZBounds*HEIGHT*numberOfTiles));
		for j in HEIGHT:
		# === Chunk Generation === | IMPLEMENT WATER BODY GENERATION
			var newBase : MeshInstance3D = MeshInstance3D.new(); # Create new plane mesh as a base
			newTile.add_child(newBase);
			newBase.mesh = PlaneMesh.new();
			newBase.set_surface_override_material(0, baseMat);
			# Create chunk instance | Type of chunk is based on district | IMPLEMENT
			var newChunk = null;
			var type : int = randi_range(0, 1); # Define chunk type
			match(type): # Zone generation, too random 
				0: # Standard chunk | roads and/or buildings
					newChunk = chunk.instantiate();
					b_chunks.append(newChunk);
				1: # Vegetation
					newChunk = StaticBody3D.new();
					var newMesh : MeshInstance3D = MeshInstance3D.new();
					newChunk.add_child(newMesh);
					newMesh.name = "TreeMesh";
					newMesh.mesh = GlobalSettings.tree_mesh_lod_2; # Defaults to low LOD
					# Auto calculate Y!
					newChunk.scale = Vector3(GlobalSettings.chunkXBounds+(GlobalSettings.chunkXBounds*0.2), 75.0, GlobalSettings.chunkZBounds+(GlobalSettings.chunkZBounds*0.2));
					newMesh.set_surface_override_material(0, treeMat);
					newMesh.cast_shadow = false;
					newMesh.rotation.y = deg_to_rad(chunkRotation); # Merge below, don't pass to generate argument!
					vegetation[i] = newChunk;
					var newTreeCol : CollisionShape3D = CollisionShape3D.new();
					newChunk.add_child(newTreeCol);
					newTreeCol.shape = BoxShape3D.new(); # No need to alter scale
					newChunk.add_to_group("Tree");
			newTile.add_child(newChunk);
			chunkRotation += 90.0; # Apply to trees also!
			if(!type): # Account for building generation
				newChunk.Generate(chunkRotation); # Run chunk generation, passes global rotation
			#if(!uniform):
				#var rot : float = randf_range(0.0, 360);
				#newChunk.rotation.y = rot; # Rotate entire chunk
			newChunk.position = Vector3(i*GlobalSettings.chunkXBounds, 0.0, j*GlobalSettings.chunkZBounds);
			if(type):
				newChunk.position += Vector3(GlobalSettings.chunkXBounds/2, 5.0, GlobalSettings.chunkZBounds/2);
			# Fix with vegeation! Optimise entire generation method?
			newBase.position = Vector3(newChunk.position.x+GlobalSettings.chunkXBounds/2, 0.0, newChunk.position.z+GlobalSettings.chunkZBounds/2);
			newCol.global_transform.origin = Vector3(newChunk.global_transform.origin.x/2+GlobalSettings.chunkXBounds/2, 0.0, newChunk.global_transform.origin.z/2+GlobalSettings.chunkZBounds/2);
			newBase.mesh.size = Vector2(GlobalSettings.chunkXBounds, GlobalSettings.chunkZBounds);
		# === Road Generation ===
			if(generation_flags[flag_indexes.ROADS]): # Uniformly generated, rotation changed, roads ALWAYS match
				var genRoads : int = randi_range(0,1);
				if(!genRoads):
					continue;
				for k in range(0, (WIDTH*HEIGHT)):
					var newRoad : MeshInstance3D = MeshInstance3D.new();
					newTile.add_child(newRoad);
					newRoad.mesh = r_mesh_1;
					newRoad.scale = Vector3(GlobalSettings.chunkXBounds/100, 1.0, GlobalSettings.chunkZBounds/100);
					roadOffset.x += GlobalSettings.chunkXBounds/WIDTH;
					if(roadOffset.x >= GlobalSettings.chunkXBounds*WIDTH):
						roadOffset.x = 0.0;
						roadOffset.z += GlobalSettings.chunkZBounds/HEIGHT;
					newRoad.position = roadOffset;
		# === Mega Building Generation ===
		if(generation_flags[flag_indexes.MEGABUILD]):
			var buildingToAdd : float = randf_range(0.0, 1.0);
			if(buildingToAdd < 0.95):
				continue;
			buildingToAdd = randi_range(0, m_buildings.size());
			var newMegaBuilding : Area3D = Area3D.new();
			newTile.add_child(newMegaBuilding);
			megaBuildings.append(newMegaBuilding);
			newMegaBuilding.add_to_group("Mega");
			var newMegaMesh : MeshInstance3D = MeshInstance3D.new();
			newMegaBuilding.add_child(newMegaMesh);
			newMegaMesh.mesh = m_buildings[buildingToAdd-1]; #? Indexing
			# Mega building collision/bounding ===
			var megaCol : CollisionShape3D = CollisionShape3D.new();
			newMegaBuilding.add_child(megaCol); # Reimplement to add child to building
			megaCol.shape = BoxShape3D.new();
			var mScale : float = randf_range(15.0, 35.0); # Certain mega buildings still small
			megaCol.shape.size = Vector3(mScale,mScale,mScale) * 0.7;
			newMegaBuilding.scale = Vector3(mScale, mScale, mScale);
			newMegaMesh.scale = Vector3(mScale/2,mScale/2,mScale/2);
			newMegaBuilding.position.x = randf_range(0.0, GlobalSettings.chunkXBounds*WIDTH);
			newMegaBuilding.position.z = randf_range(0.0, GlobalSettings.chunkZBounds*HEIGHT);
			newMegaMesh.set_surface_override_material(0, mBuildMat);
			#newCol.position.y += newCol.shape.size.y*mScale;
			#newMegaMesh.visible = false;
#			# Check for local chunks and cull
			#print("Bodies", newMegaBuilding.get_overlapping_areas());
#			for j in newMegaBuilding.get_overlapping_bodies(): # Fix!
#				print(j);
#				j.queue_free();
#			# Light
			var newLight : OmniLight3D = OmniLight3D.new();
			newMegaBuilding.add_child(newLight);
			newLight.omni_range = GlobalSettings.chunkXBounds*WIDTH;
			newLight.light_energy = 3000.0;
			newLight.light_color = Color.BLANCHED_ALMOND;
	return newTile;

func _physics_process(delta) -> void: # Vegetation generation
	for i in range(0, vRays.size()/2):
		vRays[i].position += vRayOffset;
		if(vRays[i].is_colliding() && vRays[i].get_collider().is_in_group("Ground")):
			var newTreeMesh : MeshInstance3D = MeshInstance3D.new();
			tiles[i].add_child(newTreeMesh);
			newTreeMesh.mesh = GlobalSettings.treeMesh;
			newTreeMesh.position = vRays[i].get_collision_point();
			newTreeMesh.rotation.y = randf_range(0.0, 360.0);
			#newTreeMesh.cast_shadow = 0;
			newTreeMesh.set_surface_override_material(0, treeMat);
		vRays[i].position.x += vegStepSize;
		if(vRays[i].position.x > GlobalSettings.chunkXBounds*WIDTH):
			vRays[i].position.x = 0.0;
			vRays[i].position.z += vegStepSize;
			if(vRays[i].position.z > GlobalSettings.chunkZBounds*HEIGHT):
				# Stop said vRay
				vRays.remove_at(i);
				#set_physics_process(false);

func _on_post_gen_timer_timeout():
	MegaCull();
	for i in b_chunks:
		i.mesh.visible = true;
