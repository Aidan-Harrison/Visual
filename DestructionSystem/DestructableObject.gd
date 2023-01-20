extends Node3D

@export var height : int = 2;
@export var width : int = 2;
@export var depth : int = 2;
@export var size : Vector3 = Vector3(4,4,4);

@onready var voxel = preload("res://Voxel.tscn");
@onready var simpleCol = preload("res://SimpleCollider.tscn");

# Materials
@onready var red = preload("res://Materials/Red.tres");
@onready var blue = preload("res://Materials/Blue.tres");
@onready var green = preload("res://Materials/Green.tres");
@onready var orange = preload("res://Materials/Orange.tres");

var materials = [];
var voxels = [];
var simpleColliders = [];

# Centre voxels??? Don't think I need to

func _ready():
	# Materials
	materials.append(red);
	materials.append(blue);
	materials.append(green);
	materials.append(orange);
	# Create object
		# Eventually add a draw function, conv 2D to 3D
	var spatialIterator : Vector3 = Vector3.ZERO;
	var col : int = 0;
	for i in range(0, height*width*depth):
		if(col >= materials.size()):
			col = 0;
		var newVoxel = voxel.instantiate();
		add_child(newVoxel);
		newVoxel.generate(size, materials[col]);
		newVoxel.global_transform.origin = spatialIterator;
		spatialIterator.x+=size.x;
		if(spatialIterator.x >= width*size.x/10): # Fix!
			spatialIterator.x = 0;
			spatialIterator.z += size.z/10;
		if(spatialIterator.y >= height*size.y/10):
			spatialIterator.y = 0;
			spatialIterator.x += size.z/10;
		voxels.append(newVoxel);
		col+=1;
	#ColliderGenerator();

func ColliderGenerator():
	var newSimpCol = simpleCol.instantiate();
	var newSimpCol2 = simpleCol.instantiate();
	add_child(newSimpCol);
	add_child(newSimpCol2);
	simpleColliders.append(newSimpCol);
	simpleColliders.append(newSimpCol2);
	# Set col 1 to top of mesh
	# Set col 2 to side of mesh
	newSimpCol.visual.mesh.size = Vector2(width*size.y, depth*size.z);
	newSimpCol.position = Vector3(width*size.x/2, 0.0, depth*size.z/2);
	newSimpCol2.visual.mesh.size = Vector2(width*size.y, depth*size.z);
	newSimpCol2.position = Vector3(width*size.x/2, 0.0, depth*size.z/2);
	newSimpCol2.global_rotation.x = 89.5; # ? Not sure where this value comes from but it works
	#newSimpCol.position.y += size.y/10;
	#newSimpCol2.global_transform.origin.y += 1;
	#print(newSimpCol2.global_rotation.x);
	# Apply forced global rotation!
	

func _input(event):
	if(Input.is_action_just_pressed("Break")):
		voxels[0].Activate();
	if(Input.is_action_just_pressed("Shatter")):
		for i in voxels:
			i.Activate();
	if(Input.is_action_just_pressed("Reset")):
		get_tree().reload_current_scene();
	
