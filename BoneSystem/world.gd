extends Node3D

@onready var cam = $CamSpatial/Camera3d
@onready var camSpatial = $CamSpatial

func _process(delta):
	if(Input.is_action_pressed("CamRotate")):
		pass
	# Keyboard
	if(Input.is_action_pressed("Right")):
		camSpatial.rotation.y += 0.05
	if(Input.is_action_pressed("Left")):
		camSpatial.rotation.y -= 0.05
	if(Input.is_action_pressed("Up")):
		camSpatial.rotation.x -= 0.05
	if(Input.is_action_pressed("Down")):
		camSpatial.rotation.x += 0.05

func _input(event):
	if(Input.is_action_just_pressed("Click")):
		var spaceState : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		
		var mousePos = get_viewport().get_mouse_position()
		var rayOrigin = cam.project_ray_origin(get_viewport().get_mouse_position())
		var rayEnd = rayOrigin + cam.project_ray_normal(mousePos) * 2000
		#var intersect = spaceState.intersect_ray()
