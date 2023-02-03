extends CharacterBody3D;

@onready var cam = $Camera;
@onready var flyingCars = preload("res://VFX/Cars.tscn");
@onready var cars = $CarStream;

var mouse = Vector2.ZERO;
var direction = Vector3.ZERO;
var movement = Vector3(0.0,0.0,0.0);

var baseMoveSpeed : float = 350.0;
var moveSpeed : float = baseMoveSpeed;
var shiftSpeed : float = moveSpeed * 5;
var walkSpeed : float = 1.0;
var accel : float = 10.0;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _process(delta): # Convert to get input axis
	direction = Vector3(0.0,0.0,0.0);
	if(Input.is_action_pressed("Forward")):
		direction -= transform.basis.z;
	if(Input.is_action_pressed("Left")):
		direction += transform.basis.x;
	if(Input.is_action_pressed("Backward")):
		direction -= transform.basis.x;
	if(Input.is_action_pressed("Right")):
		direction -= transform.basis.z;
	# Height
	if(Input.is_action_pressed("Up")):
		position.y += 7.0;
	elif(Input.is_action_pressed("Down")):
		position.y -= 7.0;
	if(Input.is_action_pressed("SHIFT")):
		moveSpeed = shiftSpeed;
	elif(Input.is_action_just_released("SHIFT")):
		moveSpeed = baseMoveSpeed;
	if(Input.is_action_just_pressed("WalkMode")):
		moveSpeed = walkSpeed;
		position.y = 0.1;
	direction = direction.normalized();
	velocity.x = lerpf(velocity.x, direction.x * moveSpeed, accel * delta);
	velocity.z = lerpf(velocity.z, direction.z * moveSpeed, accel * delta);
	cam.rotation.x -= mouse.y * 1.0 * delta;
	cam.rotation.x = clamp(cam.rotation.x, -90, 90);
	self.rotation.y -= mouse.x * 1.0 * delta;
	mouse = Vector2.ZERO;
	move_and_slide(); # ?? Just go raw translation!
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse = event.relative;
	if(Input.is_action_just_pressed("Pause")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	#if(Input.is_action_pressed("Reset")):
		#if(get_tree().reload_current_scene() != OK):
			#print('FAILED TO RELOAD'); # Broken as of beta 13, crashes

func _on_near_field_body_entered(body):
	if(body.is_in_group("Chunk")):
		body.mesh.cast_shadow = true;
	elif(body.is_in_group("Tree")):
		body.get_node("TreeMesh").mesh = GlobalSettings.tree_mesh_lod_1;
		# Assign cars to chunk
			# Decouple from player!
	cars.position = body.position;

func _on_near_field_body_exited(body):
	if(body.is_in_group("Chunk")):
		body.mesh.cast_shadow = false;
	elif(body.is_in_group("Tree")):
		body.get_node("TreeMesh").mesh = GlobalSettings.tree_mesh_lod_2;
