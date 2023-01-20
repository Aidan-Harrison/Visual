extends Node3D

#var baseLocation : float = $StaticBody3d.global_transform.origin.y;
@onready var dObj = preload("res://DestructableObject.tscn");
var offset : Vector3 = Vector3.ZERO;

func Iterate() -> void:
	for i in range(0, 12):
		var newObj = dObj.instantiate();
		add_child(newObj);
		newObj.position = offset;
		offset.x += newObj.size.x;
		if(offset.x >= 6*offset.x):
			offset.x = 0;
			offset.y += newObj.size.y;
			
func _ready():
	Iterate();

