extends Node3D

var entities = [];
var children = []; # max 8

var bounds : Vector3 = Vector3(6,6,6);
var depth : int = 0;
# var hasSegemented : bool = false;

@onready var visual = $Visual;
@onready var col = $Area3d/CollisionShape3d;

func _ready():
	visual.mesh.size = bounds;
	col.shape.size = bounds;
	Segment(depth);

func GenerateNode(cSize : Vector3, cPos : Vector3):
	var newNode = get_script().new();
	newNode.depth = depth;
	return newNode;

func Segment(depth):
	depth+=1;
	if(depth > 2):
		print('HALT!');
		return;
	var cSize : Vector3 = bounds/4;
	var pos : Vector3 = Vector3(-cSize.x/2, -cSize.y/2, -cSize.z/2);
	for i in range(0, 8):
		children.append(GenerateNode(cSize, pos));
		pos.x *= 4;
