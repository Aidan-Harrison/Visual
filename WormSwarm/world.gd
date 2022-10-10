extends Node3D

@onready var worm = preload('res://Worm.tscn')
@onready var bv = preload("res://BV.tscn")
var worms = []

var boundVolumeSpatial : Node3D
var boundingXRange : int = 8
var boundingZRange : int = 8
var height : int = 4
var bvSize : float = 3.0 # Implement

var volumes = []
var optLevels = []

var threadCount : int = 4
var wormSet1 = []
var wormSet2 = []
var wormSet3 = []
var wormSet4 = []

func GenerateBoundingVolumes():
	var newMarker : MeshInstance3D = MeshInstance3D.new()
	add_child(newMarker)
	newMarker.mesh = BoxMesh.new()
	boundVolumeSpatial = Node3D.new()
	add_child(boundVolumeSpatial)
	var origin : Vector3 = Vector3(boundingXRange/2, height/2, boundingZRange/2)
	var offset : Vector3 = Vector3.ZERO
	var optLevel : float = 1.0 
	for i in boundingXRange:
		for j in boundingZRange*height:
			var newBV = bv.instantiate()
			boundVolumeSpatial.add_child(newBV)
			#volumes.append(newBV)
			optLevels.append(optLevel)
			newBV.position = offset
			offset.x += newBV.scale.x
			if(offset.x >= boundingXRange*newBV.scale.x):
				offset.x = 0
				offset.z += newBV.scale.x
				if(offset.z>= boundingZRange*newBV.scale.z):
					offset.z = 0
					offset.y += newBV.scale.x
	# Offset to 0,0,0
	boundVolumeSpatial.position = Vector3(-boundingXRange-bvSize/2, 0.0, -boundingZRange-bvSize/2) # Refine

func Cull(worm):
	for i in worm.segments:
		i.visible = false

func _ready():
	randomize()
	#GenerateBoundingVolumes()
	var counter : int = 1
	for i in 56:
		var newWorm = worm.instantiate()
		add_child(newWorm)
		worms.append(newWorm)
#		match counter:
#			1:
#				wormSet1.append(newWorm)
#			2:
#				wormSet2.append(newWorm)
#			3:
#				wormSet3.append(newWorm)
#			4:
#				wormSet4.append(newWorm)
#		counter += 1
#		if(counter == 5):
#			counter = 0
		$AnimationPlayer.play('Fractal')
#	for i in wormSet2:
#		i.set_physics_process(false)
#		i.tTimer.stop()
#		for j in i.segments:
#			j.visible = false
		
func _process(delta):
	$Node3d.rotation.y += 0.004
	$Control/Label.text = str(Engine.get_frames_per_second())
	#$MeshInstance3d.rotation.x += 0.05
	#$MeshInstance3d.rotation.y += 0.05
	#$MeshInstance3d.scale += Vector3(0.05,0.05,0.05)
	#pass

func _on_timer_timeout():
	#$AnimationPlayer.play('Fractal')
	for i in worms:
		#print(i.head.position.distance_to(Vector3.ZERO))
		if(i.head.position.distance_to(Vector3.ZERO) > 1.5 && i.head.position.distance_to(Vector3.ZERO) < 5.5): # && i.head.position.distance_to(Vector3.ZERO) < 8.5):
			i.set_physics_process(false)
			i.tTimer.start()
			if(i.head.position.distance_to(Vector3.ZERO) > 4.5):
				i.tTimer.wait_time = 0.1
		#elif(i.head.position.distance_to(Vector3.ZERO) > 5.5):
			#Cull(i)
		#else:
			#i.tTimer.wait_time = 0.05
