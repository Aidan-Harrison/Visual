extends Node3D;

@onready var mesh = $MultiMeshInstance;
@onready var col = $CollisionShape3d;
@onready var buildingPlacer = $BuildingPlacer;
@onready var placeTimer = $PlacementTimer;

# === Building generation ===
var offset : Vector3 = Vector3(0.0, 50.0, 0.0);
var index : int = 0;
var height : float = 1.0;

#var mesh_AABB : AABB; # Used to calculate mesh to mesh intersections and road collision

var maxMeshCount : int = 4;
var world_index : int = 0; # Current iteration of world index, e.g. 1,2,3,...
var positions = [] # Used to prevent set_transform() bug when increasing mesh count and index

func Generate(rot : float) -> void:
	mesh.visible = false;
	col.shape.size = Vector3(GlobalSettings.chunkXBounds, 1.0, GlobalSettings.chunkZBounds); # pointless now?
	col.position = Vector3(GlobalSettings.chunkXBounds/2, 0.0, GlobalSettings.chunkZBounds/2);
	# Create road
	var newRoad : StaticBody3D = StaticBody3D.new();
	add_child(newRoad);
	var newRoadMesh : MeshInstance3D = MeshInstance3D.new();
	newRoad.add_child(newRoadMesh);
	newRoadMesh.mesh = GlobalSettings.road1;
	newRoadMesh.create_trimesh_collision(); 
	newRoadMesh.set_surface_override_material(0, GlobalSettings.baseMat);
	# Alter height?
	newRoad.scale = Vector3(GlobalSettings.chunkXBounds, GlobalSettings.chunkXBounds, GlobalSettings.chunkZBounds);
	newRoad.position = Vector3(GlobalSettings.chunkXBounds/2, 2.5, GlobalSettings.chunkZBounds/2);
	newRoad.rotation.y = deg_to_rad(rot);
	#
	offset.x = randf_range(0.0, 50.0);
	offset.z = randf_range(0.0, 50.0);
	#set_physics_process(true);

func _ready() -> void:
	#mesh_AABB = mesh.get_aabb();
	Generate(0.0);
	#set_physics_process(false);
#	col.shape.size = Vector3(GlobalSettings.chunkXBounds*0.85, 10.0, GlobalSettings.chunkZBounds*0.85);
#	col.position = Vector3(GlobalSettings.chunkXBounds/2, 0.0, GlobalSettings.chunkZBounds/2);
#
#	# Create road
#	var newRoad : StaticBody3D = StaticBody3D.new();
#	add_child(newRoad);
#	var newRoadMesh : MeshInstance3D = MeshInstance3D.new();
#	newRoad.add_child(newRoadMesh);
#	newRoadMesh.mesh = GlobalSettings.road1;
#	newRoadMesh.create_trimesh_collision(); 
#	# Alter height?
#	newRoad.scale = Vector3(GlobalSettings.chunkXBounds, GlobalSettings.chunkXBounds, GlobalSettings.chunkZBounds);
#	newRoad.position = Vector3(GlobalSettings.chunkXBounds/2, 2.5, GlobalSettings.chunkZBounds/2);
	
	# Light generation
	var chance = randf_range(0.0, 1.0);
	if(chance > 0.95):
		var newLight : OmniLight3D = OmniLight3D.new();
		add_child(newLight);
		newLight.omni_range = GlobalSettings.chunkXBounds*6;
		newLight.omni_attenuation = 0.5;
		newLight.light_energy = 300.0;
		newLight.position = Vector3(GlobalSettings.chunkXBounds/2, 50.0, GlobalSettings.chunkZBounds/2);
		newLight.light_color = GlobalSettings.colors[randi_range(0, GlobalSettings.colors.size()-1)];

func _physics_process(delta) -> void:
	buildingPlacer.position = offset;
	offset.x += 12.0;
	if(offset.x >= GlobalSettings.chunkXBounds):
		offset.x = 0.0;
		offset.z += 16.0;
		if(offset.z >= GlobalSettings.chunkZBounds):
			buildingPlacer.queue_free();
			placeTimer.queue_free();
			set_physics_process(false);

func generator() -> void:
	var xPos : int = 0;
	var zPos : int = 0;
	for i in range(0, mesh.multimesh.get_instance_count()):
		var xCol = false;
		var zCol = false;
		xPos = int(randi_range(0.0, GlobalSettings.chunkXBounds));
		zPos = int(randi_range(0.0, GlobalSettings.chunkZBounds));
		mesh.multimesh.set_instance_transform(i, Transform3D(Vector3(1.5,0.0,0.0), Vector3(0.0,height,0.0), Vector3(0.0,0.0,1.5), Vector3(xPos,0.0,zPos)));
		# Do rotations

func _on_placement_timer_timeout():
	if(buildingPlacer.is_colliding() && buildingPlacer.get_collider().is_in_group("Ground")):
		if(index < maxMeshCount):
			var height : float = randf_range(1.0,2.0);
			# X Axis, Y Axis, Z Axis, Origin | Do rotation!
			#mesh.multimesh.instance_count += 1;
			#positions.append(buildingPlacer.get_collision_point());
			mesh.multimesh.set_instance_transform(index, Transform3D(Vector3(1.0,0.0,0.0), Vector3(0.0,height,0.0), Vector3(0.0,0.0,1.0), buildingPlacer.position-Vector3(0.0,50.0,0.0)));
			index+=1;
			#mesh.multimesh.set_instance_transform(index, Transform3D(Vector3(1.0,0.0,0.0), Vector3(0.0,height,0.0), Vector3(0.0,0.0,1.0), positions[0]));
