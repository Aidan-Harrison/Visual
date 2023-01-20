extends Node3D

@export var height : int = 64;
@export var width : int = 64;
@export var nSize : float = 0.2;

@export var selectedMat : StandardMaterial3D = preload("res://Selected.tres");
@export var blankMat : StandardMaterial3D = preload("res://BlankMat.tres");

var grid = [];

func _ready():
	var xOffset : float = 0;
	var yOffset : float = 0;
	for i in range(0, height):
		for j in range(0, width):
			var newNode : MeshInstance3D = MeshInstance3D.new();
			add_child(newNode);
			grid.append(newNode);
			newNode.mesh = BoxMesh.new();
			newNode.mesh.material = blankMat;
			newNode.mesh.size = Vector3(nSize,nSize,0.2);
			newNode.global_transform.origin = Vector3(xOffset, yOffset, 0);
			xOffset+=nSize;
			if(xOffset*5 >= width): # Improve, make auto
				xOffset = 0;
				yOffset+=nSize;
	Shatter();

func HitWall(x,y) -> bool:
	return x < 0 || x > width || y < 0 || y > height;

func Clear() -> void:
	for i in grid:
		i.mesh.material = blankMat;

func Shatter() -> void:
	var xPos : int = randi_range(0, width);
	var yPos : int = randi_range(0, height);
	while(!HitWall(xPos,yPos)):
		if((yPos*width)+xPos < grid.size()):
			grid[(yPos*width)+xPos].mesh.material = selectedMat;
		var direction : int = randi_range(0,4);
		match(direction):
			0: xPos+=1;
			1: xPos-=1;
			2: yPos+=1;
			3: yPos-=1;

func _input(event):
	if(Input.is_action_just_pressed("Reset")):
		Clear();
		Shatter();
