extends Node2D

@onready var bullet = preload('res://Bullet.tscn')
@onready var laser = preload('res://Laser.tscn')

var world = null

@export var killProjectile : bool = true # Important for memory | Disable if you need projectiles to persist indefinetly
@export var killTime : float = 4.0 

@export var disabled = false
@export var spawnSpawners : bool = false
@export var isLaser : bool = false
@export var projectileCount : int = 1 # Shotgun
@export var shotgunType : int = 0
@export var spawnOffset : float = 150.0 # Distance from spawner

@export var targetPlayer : bool = false

@export var dir : int = 0 # 0 = left, 1 = up, 2 = right, 3 = down
@export var doesOscillate : bool = true # Bullet osc
@export var doesRotate : bool = false
@export var doesSwarm : bool = false
@export var isHoming : bool = false
@export var isSnake : bool = false
@export var canRoam : bool = false
@export var isLerp : bool = true # True = smoother movement
@export var canBack : bool = false # If true, bullets will NOT continully move in inital direction but follow player until death | Fixed
@export var yTop : float = -500.0 # Relative to spawner
@export var yBot : float = 500.0
@export var propogateBounds : bool = true # If true, bullet osc distances are based on spawners yTop and yBot values, else independent
@export var speed : float = 0.0
@export var rotMin : float = 0.0 # If both are set to 0, just rotate forever
@export var rotMax : float = 0.0
@export var rotationRate : float = 0.01
@export var clockwiseRotation : bool = false # Slightly nicer interface instead of setting '-'
@export var spawnRate : float = 2.0 # Rate of spawns | Fire-rate
@export var delay : float = 0.0 # Delay between spawns | Interval

var canRotate : bool = false
var canMove : bool = false
var peaked : bool = false
var paused : bool = false
var player = null
var curProjectiles = []
var heads = []

# References
@onready var kTimer = $KillTimer
@onready var sTimer = $SpawnTimer
@onready var dTimer = $DelayTimer
@onready var menuButton = $MenuButton
@onready var toggleButton = $Toggle

var spawnLocations = []

# Queue
var front : int = -1
var rear : int = -1
var size : int = 20
var projectileQueue = [] # Compress curProjectiles and this to be same thing!
func full() -> bool:
	if(front == 0 && rear == size):
		return true
	return false
func empty() -> bool:
	if(front == -1):
		return true
	return false
func qTop():
	return projectileQueue[rear]
func qPush(proj):
	if(full()):
		return
	if(front == -1):
		front+=1
	rear+=1
	if(projectileQueue.size() - rear < 4):
		projectileQueue.resize(projectileQueue.size()+6)
	projectileQueue[rear] = proj
func qPop():
	if(empty()):
		return
	var result = projectileQueue[rear]
	if(front >= rear):
		front = -1
		rear = -1
	else:
		front+=1
	return result
	
func BoundsCheck(vec) -> bool:
	return vec.x > 0 && vec.x < DisplayServer.window_get_size().x && vec.y > 0 && vec.y < DisplayServer.window_get_size().y
	
func Snake():
	var newHead = bullet.instantiate()
	world.add_child(newHead)
	newHead.doesOscilate = doesOscillate
	newHead.position = position
	newHead.globalDir = dir
	newHead.position.x-=100.0
	newHead.isSnake = true
	newHead.roaming = canRoam
	heads.append(newHead)
	curProjectiles.append(newHead)
	var xOffset = 0.0
	for i in projectileCount:
		var newChild = bullet.instantiate()
		world.add_child(newChild)
		newChild.doesOscilate = doesOscillate
		newChild.globalDir = dir
		newChild.position = Vector2(position.x+xOffset, position.y)
		newHead.children.append(newChild)
		xOffset += 100.0

func CalcSpawnPos(overWrite : bool = false): # Take into account rotation
	if(projectileCount > 1 && shotgunType == -1): # Straight
		spawnLocations.resize(projectileCount) # Optimise
		for i in range(0, projectileCount):
			spawnLocations[i] = position
	elif(projectileCount > 1 && shotgunType == 0): # Wall
		var yShift : float = 0.0
		var length = spawnOffset*projectileCount
		var startPos = position.y - length/3
		for i in range(projectileCount):
			var offsetY : float = startPos - spawnOffset + yShift
			var newPos : Vector2 = Vector2(position.x-spawnOffset, offsetY)
			yShift += spawnOffset
			if(!overWrite):
				spawnLocations.append(newPos)
			else:
				spawnLocations[i] = newPos
	elif(projectileCount > 1 && shotgunType == 1): # Arrow
		var xShift : float = 0.0
		var yShift : float = 0.0
		for i in range(projectileCount):
			var offsetX : float = position.x - xShift
			var offsetY : float = position.y - spawnOffset + yShift
			var newPos : Vector2 = Vector2(offsetX, offsetY)
			yShift += spawnOffset
			if(i >= projectileCount/2):
				xShift += spawnOffset
			else:
				xShift -= spawnOffset
			if(!overWrite):
				spawnLocations.append(newPos)
			else:
				spawnLocations[i] = newPos
	elif(projectileCount > 1 && shotgunType == 2): # Radial
		var theta : float = 0.0
		for i in range(projectileCount):
			var x : float = position.x + spawnOffset * sin(theta)
			var y : float = position.y + spawnOffset * cos(theta)
			var newPos : Vector2 = Vector2(x,y)
			#print(newPos)
			theta += spawnOffset # Make always even
			if(!overWrite):
				spawnLocations.append(newPos)
			else:
				spawnLocations[i] = newPos
			# calculate offset
			# Offset x and y according to total count, lower values the higher the count

func _ready():
	randomize()
	world = get_parent()
	player = world.get_node('Player')
	kTimer.wait_time = killTime
	sTimer.wait_time = spawnRate
	if(delay > 0.0):
		dTimer.wait_time = delay
	if(disabled):
		sTimer.autostart = false
		sTimer.stop()
		set_process(false)
		$Button.visible = false
	menuButton.set_as_top_level(true)
	toggleButton.set_as_top_level(true)
	if(disabled):
		set_process(false)
	match(dir): # Fix
		1:
			rotation = rad_to_deg(90)
		2:
			rotation = rad_to_deg(180)
		3:
			rotation = rad_to_deg(-90)
	projectileQueue.resize(projectileCount*2) # Dynamically resize when needed
	if(canRoam):
		$RoamTimer.start()
		dir = 4
	CalcSpawnPos()

func Laser():
	# Set to fire only after ending
	for i in spawnLocations:
		var newLaser = laser.instantiate()
		world.add_child(newLaser)
		curProjectiles.append(newLaser)
		qPush(newLaser)
		if(speed > 0): # Make option
			newLaser.doesDestroy = true
		if(doesSwarm):
			var newX = randf_range(position.x-400.0, position.x+400.0)
			var newY = randf_range(position.y-400.0, position.y+400.0)
			var newLaserLocation = Vector2(newX,newY)
			newLaser.position = newLaserLocation
			#newLaser.look_at(world.get_node('Player').position) # Fix!
		else:
			newLaser.position = i
			newLaser.rotation = rotation
		sTimer.stop()
		dTimer.start()

func Spawner():
	#var newSpawner = Global.spawner.instantiate()
	#world.add_child(newSpawner)
	# lerp to position
	pass

func _on_timer_timeout():
	if(disabled):
		return
	if(isLaser):
		Laser()
		return
	elif(isSnake):
		Snake()
		return
	elif(spawnSpawners):
		Spawner()
		return
	for i in spawnLocations:
		var newBullet = bullet.instantiate()
		world.add_child(newBullet) # Not doing a constructor to avoid function call overhead
		newBullet.rotation = rotation
		newBullet.position = i
		newBullet.globalDir = dir
		newBullet.doesOscilate = doesOscillate
		newBullet.topPointer.position.y = yTop
		newBullet.botPointer.position.y = yBot
		newBullet.roaming = canRoam
		if(canBack): # Check
			newBullet.target = player
			newBullet.canBack = canBack
		curProjectiles.append(newBullet)
		qPush(newBullet)
	#newBullet.oscA = position.y - newBullet.oscA
	#newBullet.oscB = position.y + newBullet.oscB
	#print(position.y - newBullet.oscA)
	#print(position.y + newBullet.oscB)

func _physics_process(delta): # Non gameplay logic
	if(targetPlayer):
		look_at(Vector2(0,player.position.y))
	if(canRotate):
		# Below avoids mouse coord conversion and offset issues, as well as recentering bug
		if(get_global_mouse_position().y < position.y):
			rotation += rotationRate
		elif(get_global_mouse_position().y > position.y):
			rotation -= rotationRate
		rotation = clamp(rotation, -1.5, 1.5)
	if(canMove):
		position.y = get_global_mouse_position().y 
		CalcSpawnPos(true)
	toggleButton.position.x = position.x-50
	toggleButton.position.y = position.y+75
	menuButton.position.x = position.x-50
	if(isHoming): # Improve | Add ability to back-track
		for i in curProjectiles: # Add speed clamp
			if(i != null):
				i.look_at(player.position)
				if(isLerp && !canBack):
					i.direction = lerp(i.direction, player.position, 1.0)
				elif(isLerp && canBack):
					pass
				elif(!isLerp && !canBack):
					#i.direction.x = move_toward(i.direction.x, player.position.x, 100.0)
					i.position.y = move_toward(i.position.y, player.position.y, 6.0)
				else: 
					#i.direction.x = move_toward(i.direction.x, player.position.x, 100.0)
					i.direction.y = move_toward(i.direction.y, player.position.y, 100.0) # Change

func _process(delta):
	# Oscilate
	if(!peaked):
		position.y -= speed
	else:
		position.y += speed
	if(position.y < yTop):
		peaked = true
	elif(position.y > yBot):
		peaked = false
	if(doesRotate && clockwiseRotation):
		rotation += rotationRate
	elif(doesRotate && !clockwiseRotation):
		rotation -= rotationRate

func _on_button_button_down():
	canRotate = true
	set_process(false)
	if(world.spawnMenu.visible):
		world.spawnMenu.visible = false
	
func _input(event):
	if(Input.is_action_just_pressed('Click') && canRotate):
		canRotate = false
		if(!disabled):
			set_process(true)
	elif(Input.is_action_just_pressed('Click') && canMove):
		canMove = false
		if(!disabled):
			set_process(true)
		yTop = position.y - -yTop
		yBot = position.y + yBot

func State():
	if(disabled): 
		disabled = false
		set_process(true)
		dTimer.start()
		sTimer.start()
	else: 
		disabled = true
		set_process(false)
		dTimer.stop()
		sTimer.stop()

func _on_handle_button_down():
	canMove = true
	set_process(false)
	if(world.spawnMenu.visible):
		world.spawnMenu.visible = false

func _on_toggle_pressed(): # Prevent pause override
	if(!paused):
		State()
	
func _on_delay_timer_timeout():
#	if(isFiring):
#		isFiring = false
#	else:
#		isFiring = true
	sTimer.start()

func _on_menu_button_pressed():
	if(world.spawnMenu.visible):
		world.spawnMenu.visible = false
	else:
		world.spawnMenu.visible = true

func _on_kill_timer_timeout(): # Slowly clear queue
	if(qTop() != null):
		qPop().queue_free()
#	for i in curProjectiles:
#		if(i != null):
#			i.queue_free()

func _on_roam_timer_timeout(): # How often direction is changed
	if(isSnake):
		for i in heads:
			if(i != null):
				var newDir = Vector2(randf_range(i.position.x-100.0, i.position.x+100.0), randf_range(i.position.y-100.0, i.position.y+100.0))
				if(BoundsCheck(newDir)):
					i.direction = newDir
		return
	for i in curProjectiles: # Causes projectile to freely roam around, best used in conjunction with snake
		if(i != null):
			var newDir = Vector2(randf_range(i.position.x-100.0, i.position.x+100.0), randf_range(i.position.y-100.0, i.position.y+100.0))
			if(BoundsCheck(newDir)):
				i.direction = newDir
