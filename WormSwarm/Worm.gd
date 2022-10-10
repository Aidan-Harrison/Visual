extends Node3D

var world = null
var head = null
var segments = []
var isChanging : bool = false
var range : float = 4.0
var bounds : float = 12.0

var scaleStart : int = 40
var scaleEnd : int = 80

var resolution : int = 1 # Compresses X amount of meshes into a single segment, scales accordingly
# Counter intuitively, higher resolution = more performance

var hasSub : bool = false
var doesRotate : bool = true # Sub-segment rotation
var doesWave : bool = true

@export var disabled : bool = false
@export var subOffset : int = 2
@export var segCount : int = 20
@export var headMesh : Mesh = null
@export var subMesh : Mesh = null
@onready var seg = preload('res://Segment.tscn')
@onready var mat = preload("res://OldMaterial.tres")
@onready var wTimer = $WaveTimer
@onready var tTimer = $TickTimer

var direction = Vector3.ZERO
var newDir = Vector3.ZERO
var waveCounter : int = 0
var optIterLevel : int = 10

func _ready():
	world = get_parent()
	var newHead = seg.instantiate()
	world.add_child(newHead)
	var newCol : CollisionShape3D = CollisionShape3D.new()
	newHead.add_child(newCol)
	newCol.shape = BoxShape3D.new()
	var resOffset : float = 1.0
	var hFocalPoint : Node3D = Node3D.new()
	head = newHead
	var xOffset : float = 0.0
	for i in segCount:
		var newSeg = seg.instantiate()
		var focalPoint : Node3D = Node3D.new()
		world.add_child(newSeg)
		segments.append(newSeg)
		for j in resolution:
			var subSeg : MeshInstance3D = MeshInstance3D.new()
			newSeg.get_node('MeshInstance3d').add_child(subSeg)
			subSeg.position.z = resOffset
			subSeg.mesh = newSeg.get_node('MeshInstance3d').mesh
			subSeg.mesh.surface_set_material(0, mat)
			resOffset += 1.0 # Scale
		newSeg.add_child(focalPoint)
		if(resolution > 0):
			focalPoint.position = newSeg.get_node('MeshInstance3d').get_children().back().position
		focalPoint.name = 'FocalPoint'
		if(hasSub):
			if(i % subOffset == 0):
				newSeg.get_node('SubSegment').mesh = subMesh
				#newSeg.get_node('SubSegment').mesh.set_surface_material = "res://Second.tres"
				newSeg.get_node('SubSegment').rotation.x = 90
		xOffset += resOffset
		newSeg.position.z -= xOffset
		var segScale = 1.0
		if(i > scaleStart && i < scaleEnd): # Move to creation
			segments[i].scale = Vector3(segScale,segScale,segScale)
			if(segScale > 0.0):
				segScale -= 0.02 # Scale with section size
		resOffset = 1.0 # Scale with mesh
		
	if(doesWave):
		wTimer.start()
	if(disabled):
		set_physics_process(false)
	$TickTimer.autostart = false

func Shift():
	# Lock to radius, prevent harsh turns! | Option
	newDir = Vector3(direction.x-randf_range(-range,range),direction.y-randf_range(-range,range),direction.z-randf_range(-range,range))
	#var newRelDir = Vector3(randf_range(head.position.x-range, head.position.x+range), randf_range(head.position.y-range, head.position.y+range), randf_range(head.position.z-range, head.position.z+range))
	#direction = newRelDir
	#var newPointer : MeshInstance3D = MeshInstance3D.new()
	#world.add_child(newPointer)
	#newPointer.mesh = SphereMesh.new()
	#newPointer.position = Vector3(newDir.x-1, newDir.y, newDir.z)
	if(newDir.x > bounds || newDir.x < -bounds || newDir.y > bounds || newDir.y < -bounds || newDir.z > bounds || newDir.z < -bounds):
		Shift()
		
func _physics_process(delta):
	direction = lerp(direction, newDir, 0.02)
	if(direction.distance_to(newDir) < 3.0):
		Shift()
	#print(direction)
	head.position = lerp(head.position, direction, 0.1)
	if(head.position != direction):
		head.look_at(direction, Vector3.UP)
	if(direction.x > head.position.x):
		head.rotation.z = 45.0
	elif(direction.x < head.position.x):
		head.rotation.z = -45.0
	var falloff = 0.1
	var segScale = 1.0
	# Head
	if(segments[0].position.distance_to(head.position) > 0.5):
		segments[0].position = lerp(segments[0].position, head.position, falloff)
	elif(segments[0].position.distance_to(head.position) > 1.0):
		segments[0].position = lerp(segments[0].position, head.position, falloff*1.5)
	if(segments[0].position != head.position):
		segments[0].look_at(head.position, Vector3.UP)
	# Segments
	for i in range(1,segments.size()): # Optimise
		if(segments[i].position.distance_to(segments[i-1].get_node('FocalPoint').global_transform.origin) > 0.5):
			#segments[i].position = lerp(segments[i].position, segments[i-1].position, oint').position, falloff)
			segments[i].position = lerp(segments[i].position, segments[i-1].get_node('FocalPoint').global_transform.origin, falloff)
		elif(segments[i].position.distance_to(segments[i-1].get_node('FocalPoint').global_transform.origin) > 1.0):
			segments[i].position = lerp(segments[i].position, segments[i-1].get_node('FocalPoint').global_transform.origin, falloff*1.5)
		segments[i].look_at(segments[i-1].get_node('FocalPoint').global_transform.origin, Vector3.UP)
		if(doesRotate):
			#segments[i].get_node('SubSegment').rotation.x += 0.1
			pass
		#i += optIterLevel

func _on_timer_timeout():
	if(waveCounter >= segCount):
		waveCounter = 0
	#segments[waveCounter].get_node('AnimationPlayer2').play('Leg')
	#segments[waveCounter].get_node('AnimationPlayer').play('Wave')
	waveCounter += 1

func _on_tick_timer_timeout():
	direction = lerp(direction, newDir, 0.02)
	if(direction.distance_to(newDir) < 3.0):
		Shift()
	#print(direction)
	head.position = lerp(head.position, direction, 0.1)
	if(head.position != direction):
		head.look_at(direction, Vector3.UP)
	if(direction.x > head.position.x):
		head.rotation.z = 45.0
	elif(direction.x < head.position.x):
		head.rotation.z = -45.0
	var falloff = 0.1
	# Head
	if(segments[0].position.distance_to(head.position) > 0.5):
		segments[0].position = lerp(segments[0].position, head.position, falloff)
	elif(segments[0].position.distance_to(head.position) > 1.0):
		segments[0].position = lerp(segments[0].position, head.position, falloff*1.5)
	if(segments[0].position != head.position):
		segments[0].look_at(head.position, Vector3.UP)
	# Segments
	for i in range(1,segments.size()):
		if(segments[i].position.distance_to(segments[i-1].get_node('FocalPoint').global_transform.origin) > 0.5):
			segments[i].position = lerp(segments[i].position, segments[i-1].get_node('FocalPoint').global_transform.origin, falloff)
		elif(segments[i].position.distance_to(segments[i-1].get_node('FocalPoint').global_transform.origin) > 1.0):
			segments[i].position = lerp(segments[i].position, segments[i-1].get_node('FocalPoint').global_transform.origin, falloff*1.5)
		segments[i].look_at(segments[i-1].get_node('FocalPoint').global_transform.origin, Vector3.UP)
		if(doesRotate):
			#segments[i].get_node('SubSegment').rotation.x += 0.1
			pass
		i += optIterLevel # Check!
