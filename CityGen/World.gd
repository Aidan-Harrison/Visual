extends Node3D;

# Core
@onready var building = preload("res://Building.tscn");
@onready var chunk = preload("res://Chunk.tscn");
# Roads
@onready var r_mesh_1 = preload("res://Roads/CityGenRoadTile1.obj");

# Mega buildings
@onready var mB1 = preload("res://BuildingComponents/MegaBuilding1.obj");
@onready var mB2 = preload("res://BuildingComponents/MegaBuilding2.obj");

# Highways
@onready var highwayStraight = preload("res://Roads/CityGenHighway.obj");

# Extra
@onready var treeMesh = preload("res://Extra/CityGenTrees.obj");
@onready var treeMat = preload("res://Extra/TreeMat.tres");
@onready var baseMat = preload("res://Extra/BaseMat.tres");
@onready var buildMat = preload("res://Extra/BuildingMat.tres");

# Roads
@onready var road1 = preload("res://Roads/Road1.tscn");

# Below auto scales
var numberOfTiles : int = 4;
# Chunks per tile | W * H
var WIDTH : int = 6;
var HEIGHT : int = 6;
var roads = [
	[]
];
var m_buildings = [];
var tiles = [];
var districts = []; # Map instead?
var vRays = [];
var iVRayPos = []; # Initial positions of vegetation rays
var vRayOffset : Vector3 = Vector3.ZERO;
var light_colors = [Color.RED, Color.BLANCHED_ALMOND, Color.DARK_ORANGE];
var vegStepSize : float = 225.0;
var roadOffset : Vector3 = Vector3(0.0, 7.0, 0.0); # Starts at centre of first tile
var rOffsetStart : Vector3 = roadOffset;

# Interface
	# === ROADS, LIGHTS, MEGA BUILDINGS ===
enum flag_indexes{ROADS, LIGHTS, MEGABUILD, HIGHWAY}; # Remove lights generation
@export var generation_flags = [false,false,true,true];
@export var uniform : bool = false;
@export var highwaySectionLength : int = 3;
@export var numOfHighways : int = 1; # Height is self solving

func _ready():
	m_buildings.append(mB1);
	m_buildings.append(mB2);
	get_viewport().debug_draw = 0;
	for _i in range(0, numberOfTiles): # Vegetation rays, used for tree generation
		var vegRay : RayCast3D = RayCast3D.new();
		add_child(vegRay);
		vRays.append(vegRay);
		vegRay.target_position.y = -1000;
		vegRay.debug_shape_thickness = 5;
		vegRay.debug_shape_custom_color = Color.RED;
	call_deferred("Tile");
	if(generation_flags[flag_indexes.HIGHWAY]):
		var height : float = 0.0;
		for _i in numOfHighways:
			Highway(height);
			height -= 100.0;

func AddToWorld(data):
	for i in data:
		add_child(data);

func Tile() -> void:
	var posOffset : Vector2 = Vector2.ZERO;
	for i in numberOfTiles:
		vRays[i].position = Vector3(posOffset.x, 750.0, posOffset.y);
		iVRayPos.append(vRays[i].position);
		tiles.append(Generate()); # Genereate tile of chunks
		tiles[i].global_transform.origin = Vector3(posOffset.x, 0.0, posOffset.y);
		posOffset.x += GlobalSettings.chunkXBounds * WIDTH;
		if(i % numberOfTiles/2 == 0 && i != 0):
			posOffset.x = 0;
			posOffset.y += GlobalSettings.chunkZBounds * HEIGHT;
			
func Highway(height : float) -> void: # === Highway Generation ===
	# Generate starting position
		# Improve/fix starting generation!
	var startingPos : Vector3 = Vector3(randi_range(GlobalSettings.chunkXBounds/2, GlobalSettings.chunkXBounds*WIDTH*2), height, randi_range(GlobalSettings.chunkZBounds/2, GlobalSettings.chunkZBounds*HEIGHT*2));
	var head : Vector3 = startingPos; # Position of road
	var validDirections = [true,true,true,true];
	var counter : int = 0;
	var direction : int = 1;
	for i in range(WIDTH*HEIGHT*2):
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
		if(head.x + GlobalSettings.chunkXBounds >= GlobalSettings.chunkXBounds*WIDTH):
			validDirections[1] = false;
		if(head.z - GlobalSettings.chunkZBounds <= 0.0):
			validDirections[2] = false;
		if(head.z + GlobalSettings.chunkZBounds >= GlobalSettings.chunkZBounds*HEIGHT):
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

func Generate() -> Node3D:
	# === Tile Generation ===
	var newTile : StaticBody3D = StaticBody3D.new(); # Stores EVERYTHING
	add_child(newTile);
	var newCol : CollisionShape3D = CollisionShape3D.new(); # Used for ray collision
	newTile.add_child(newCol);
	districts.append(randi_range(0,3));
	newCol.shape = BoxShape3D.new();
	newCol.shape.size = Vector3(GlobalSettings.chunkXBounds * WIDTH, 1.0, GlobalSettings.chunkZBounds * HEIGHT);
	newTile.add_to_group("Ground");
	for i in WIDTH: # Convert to single for loop?
		for j in HEIGHT:
		# === Chunk Generation === | IMPLEMENT WATER BODY GENERATION
			var newBase : MeshInstance3D = MeshInstance3D.new(); # Create new plane mesh as a base
			newTile.add_child(newBase);
			newBase.mesh = PlaneMesh.new();
			newBase.set_surface_override_material(0, baseMat);
			# Create chunk instance | Type of chunk is based on district | IMPLEMENT
			var newChunk = chunk.instantiate();
			newTile.add_child(newChunk);
			if(!uniform):
				var rot : float = randf_range(0.0, 360);
				newChunk.rotation.y = rot; # Rotate entire chunk
			newChunk.global_transform.origin = Vector3(i*GlobalSettings.chunkXBounds, 0.0, j*GlobalSettings.chunkZBounds);
			newBase.global_transform.origin = Vector3(newChunk.global_transform.origin.x+GlobalSettings.chunkXBounds/2, 0.0, newChunk.global_transform.origin.z+GlobalSettings.chunkZBounds/2);
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
		# === Light Generation ===
		if(generation_flags[flag_indexes.LIGHTS]):
			var newLight = OmniLight3D.new();
			newTile.add_child(newLight);
			newLight.omni_range = 10000;
			newLight.light_energy = 100.0;
			newLight.light_color = light_colors[randi_range(0,light_colors.size()-1)];
			newLight.position = Vector3(GlobalSettings.chunkXBounds/2, 0.0, GlobalSettings.chunkZBounds/2);
		# === Mega Building Generation ===
		if(generation_flags[flag_indexes.MEGABUILD]):
			var buildingToAdd = randi_range(0,1);
			if(!buildingToAdd):
				continue;
			buildingToAdd = randi_range(0, m_buildings.size());
			var newMegaBuilding = MeshInstance3D.new();
			newTile.add_child(newMegaBuilding);
			newMegaBuilding.mesh = m_buildings[buildingToAdd-1]; #? Indexing
			var mScale : float = randf_range(50.0, 200.0);
			newMegaBuilding.scale = Vector3(mScale,mScale,mScale);
			newMegaBuilding.global_transform.origin.x = randf_range(0.0, GlobalSettings.chunkXBounds*WIDTH);
			newMegaBuilding.global_transform.origin.z = randf_range(0.0, GlobalSettings.chunkZBounds*HEIGHT);
			newMegaBuilding.set_surface_override_material(0, buildMat);
	return newTile;

func _physics_process(delta) -> void: # Vegetation generation
	for i in range(0,vRays.size()):
		vRays[i].position += vRayOffset;
		if(vRays[i].is_colliding() && vRays[i].get_collider().is_in_group("Ground")):
			var newTreeMesh = MeshInstance3D.new();
			tiles[i].add_child(newTreeMesh);
			newTreeMesh.mesh = treeMesh;
			newTreeMesh.position = vRays[i].get_collision_point();
			newTreeMesh.scale.x *= 2.0;
			newTreeMesh.scale.z *= 2.0;
			newTreeMesh.rotation.y = randf_range(0.0, 360.0);
			newTreeMesh.cast_shadow = 0;
			newTreeMesh.set_surface_override_material(0, treeMat);
		vRays[i].position.x += vegStepSize;
		if(vRays[i].position.x > GlobalSettings.chunkXBounds*WIDTH):
			vRays[i].position.x = 0.0;
			vRays[i].position.z += vegStepSize;
