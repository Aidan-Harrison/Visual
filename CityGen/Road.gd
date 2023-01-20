extends Node3D

var points = []
var parent = null

func _ready():
	parent = get_parent()

func gen():
	for i in range(0,2):
		var newPoint = Node3D.new()
		points.append(newPoint)
		add_child(newPoint)
