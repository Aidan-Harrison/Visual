extends Node2D

var isMoving : bool = false

func _ready():
	set_process(false)

func _process(delta):
	position = lerp(position, get_global_mouse_position(), 0.1)

func _input(event):
	if Input.is_action_just_pressed("Toggle"):
		if(isMoving):
			set_process(false)
			isMoving = false
		else:
			set_process(true)
			isMoving = true

func _on_col_body_entered(body):
	body.queue_free()
