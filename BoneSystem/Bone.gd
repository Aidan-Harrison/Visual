extends Node3D

var parentBone = null
var childBone = null

var isActive : bool = false # Can update
var selected : bool = false

func _ready():
	set_process(false)
	
func _process(delta):
	look_at(childBone.global_transform.origin, Vector3.UP)
	if(selected):
		pass
