extends Node3D

@export var height : int = 1;
@export var width : int = 8;
@export var depth : int = 8;
@export var bounds : Vector3 = Vector3(6,6,6);
@onready var node = preload("res://Tree/Node.tscn");
@onready var vTimer = $Visualise;
var vCounter : int = 0;

# Materials:
@onready var red = preload("res://Materials/TreeVisual.tres");
@onready var blue = preload("res://Materials/Blue.tres");

var nodes = []

# FIX MATERIAL ASSIGNMENT

#func _process(delta):
	#$"../CameraSpatial".rotate_y(0.0075);

func _ready(): # Generate base
	var offset : Vector3 = Vector3.ZERO;
	var amount : int = height*width*depth+width;
	for i in amount:
		var newNode = node.instantiate();
		add_child(newNode);
		newNode.visual.mesh.material = red;
		newNode.global_transform.origin = offset;
		offset.x += bounds.x;
		nodes.append(newNode);
		# Position
		if(offset.x > width * bounds.x):
			offset.y += bounds.y;
			offset.x = 0;
		if(offset.y > height * bounds.y):
			offset.z += bounds.z;
			offset.y = 0;
	#Segment(nodes[0]);
	#ZoneSeg(0,8);
	# 2 -> 9
	#Dive(2, 5);
	#Dive(3, 5);
	#Dive(3, 5);
	#Dive(3, 5); # Fix for n amount of depths. currently only 3 from base
	#Dive(4, 5);
	#Dive(5, 5);
	#Dive(6, 5);
	# Dive deeper:
	#Dive(6, 5); # 6 has already been segmented, so go into it
	# Normal
	#Dive(7, 5);
	#Dive(8, 5);
	#Dive(9, 5);
	
func Dive(localDepth : int, startingNode : int):
	var currentChildren = nodes[startingNode].get_children();
	for i in range(0, currentChildren.size()):
		if(i == localDepth):
			if(currentChildren[i].get_children().size() > 2):
				currentChildren = currentChildren[i].get_children();
	Segment(currentChildren[localDepth], red);
	
func ZoneSeg(sPos : int, ePos : int) -> void:
	if(sPos == ePos):
		print('Equal vectors');
		return;
	for i in range(0,nodes.size()):
		if(i >= sPos && i <= ePos):
			Segment(nodes[i], blue);

func Segment(curNode, material):
	var posOffset : Vector3 = curNode.bounds/2;
	var pos : Vector3 = Vector3(curNode.global_transform.origin.x-posOffset.x/2, curNode.global_transform.origin.y-posOffset.y/2, curNode.global_transform.origin.z-posOffset.z/2);
	for i in range(0, 8):
		var newNode = node.instantiate();
		curNode.add_child(newNode);
		newNode.visual.mesh.material = material;
		newNode.global_transform.origin = pos;
		newNode.scale *= 0.5; # Questionable
		newNode.bounds = curNode.bounds/2;
		pos.x += newNode.scale.x*curNode.bounds.x;
		if(pos.x > curNode.global_transform.origin.x+curNode.bounds.x/2):
			pos.x = curNode.global_transform.origin.x-posOffset.x/2;
			pos.y += newNode.scale.y*curNode.bounds.y;
			if(pos.y > curNode.global_transform.origin.y + curNode.bounds.y/2):
				pos.y = curNode.global_transform.origin.y-posOffset.y/2;
				pos.z += newNode.scale.z*curNode.bounds.z;

func MaterialSet(index) -> void:
	var children = nodes[index].get_children();
	print(nodes[0].visual.mesh.material);

func _on_visualise_timeout():
	if(vCounter == nodes.size()-1):
		vTimer.stop();
		return;
	Segment(nodes[vCounter], red);
	vCounter+=1;
	if(vCounter == 6):
		MaterialSet(0);
