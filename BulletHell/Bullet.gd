extends Node2D

# This is a universal bullet handler
# @export variables are available to view in the editor, nothing more
@export var startingX : float = 0.0 # Starting position in world space, if spawned by a spawner, relative offset instead
@export var startingY : float = 0.0

@export var velocity : float = 1200.0
@export var speedMod : int = 8
@export var maxSpeed : float = 1000.0
@export var acceleration : float = 100.0
@export var dampening : float = 0.0

@export var doesOscilate : bool = true # If true the oscA and oscB variables are accounted for and bullet shall alter trajectory
@export var oscA : float = -700.0 # Lower oscillation bound in world space
@export var oscB : float = 700.0
@export var oscRate : float = 12000.0 # Rate it which oscillation happens, independently modifiable speed value
@export var colX : float = 128.0 # Size of collider in pixels, auto scales with sprite size
@export var colY : float = 128.0
@export var sizeX : float = 1.0
@export var sizeY : float = 1.0

@export var waveType : int = 0

@export var sprite : Texture2D
@export var isSnake : bool = false
@export var damage : int = 1
@export var left : bool = true # Moves right-left by default

# References
@onready var sprRef = $Texture # References texture for several uses
@onready var topPointer = $TopPointer
@onready var botPointer = $BotPointer

var globalDir : int = 0
var direction : Vector2 = Vector2.ZERO # Trajectory is stored as a 2D vector (x and y position)
var peaked : bool = false # Used for oscillation, see below
var swapped : bool = false # user for oscillation, see below
var canBack : bool = false # Used to allow for full freedom target tracking
var roaming : bool = false
var target = null

var children = []

var overrideSpawner : bool = false # Override certain spawner settings

enum WAVETYPES{SINE,SQUARE,SAW}

# Bullet constructor
func Setup(): 
	position.x = startingX
	position.y = startingY
	scale = Vector2(sizeX,sizeY)
	colX = scale.x / 10
	colY = scale.x / 10
	if(doesOscilate):
		$Timer.start()
	#col.size.x = colX
	#col.size.y = colY
	topPointer.set_as_top_level(true)
	botPointer.set_as_top_level(true)
	
func _ready():
	Setup() 
	#self.apply_central_impulse(Vector2(-velocity * speedMod, direction.y * oscRate))
	
# WORLD SPACE!!!
func _process(delta): # Exectues once per frame
	if(doesOscilate):
		if(!peaked):
			direction.y = oscB
		else:
			direction.y = oscA
		if(position.y < topPointer.position.y):
			peaked = false
			if(waveType == WAVETYPES.SAW):
				direction.y = oscB-50
		elif(position.y > botPointer.position.y):
			peaked = true
			if(waveType == WAVETYPES.SAW):
				direction.y = oscA+50
		#$DirPointer.position = direction
	# cos(45.0)
	if(globalDir != 4):
		direction.x = velocity
	if(canBack):
		direction == target.position
		return
	if(isSnake): # Force maximum distance
		var falloff : float = 1.0
		for i in range(0, children.size()):
			if(children[i] != null || !is_instance_valid(children[i]) || !is_instance_valid(children[i-1])): # Fix!
				if(i-1 >= 0 && children[i].position.distance_to(children[i-1].position) < 1):
					continue
				children[i].position.y = clamp(children[i].position.y, children[i-1].position.y-200, children[i-1].position.y+200.0)
				children[i].position.y = lerp(children[i].position.y, position.y, falloff)
				falloff -= 0.2
	match globalDir:
		0: # Left
			self.apply_force(Vector2(-direction.x * speedMod * delta, direction.y * oscRate * delta) * acceleration * delta, position)
			self.linear_velocity.x = clamp(self.linear_velocity.x, 1.0, -maxSpeed)
		1: # Right
			self.apply_force(Vector2(direction.x * speedMod * delta, direction.y * oscRate * delta) * acceleration * delta, position)
			self.linear_velocity.x = clamp(self.linear_velocity.x, 1.0, maxSpeed)
		2: # Up
			self.apply_force(Vector2(direction.x * oscRate * delta, -direction.y * speedMod * delta) * acceleration * delta, position)
			self.linear_velocity.y = clamp(self.linear_velocity.y, 1.0, maxSpeed)
		3: # Down
			self.apply_force(Vector2(direction.x * oscRate * delta, direction.y * speedMod * delta) * acceleration * delta, position)
			self.linear_velocity.y = clamp(self.linear_velocity.y, 1.0, maxSpeed)
		4: # FREE
			position.x = move_toward(position.x, direction.x, 10.1)
			position.y = move_toward(position.y, direction.y, 10.1)
	if(waveType == WAVETYPES.SQUARE):
		position.y = clamp(position.y, oscA-100, oscB+100)

func _on_timer_timeout(): # Oscillation timer function
	#print("Swap")
	pass
#	if(swapped):
#		$DirPointer.position.y = oscA
#		swapped = false
#	else:
#		$DirPointer.position.y = oscB
#		swapped = true
