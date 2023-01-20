extends StaticBody3D

var yOffset : float = 0.0

@onready var buildMat = preload("res://Build.tres")

# Detail Meshes
@onready var bracket1 = preload("res://BuildingComponents/Bracket1.tscn")
@onready var spire1 = preload("res://BuildingComponents/Spire1.tscn")
@onready var dome1 = preload("res://BuildingComponents/Dome1.tscn")
@onready var ac1 = preload("res://BuildingComponents/AC1.tscn")

var details = []

var isSquare = false

func _ready():
	details.append(bracket1) 
	details.append(spire1)
	details.append(dome1)
	details.append(ac1)
	gen()
	
func _process(delta):
	$Spatial.rotate_y(0.5 * delta)

func gen():
	var direction : int = 0
	var buildingHeight : int = int(randf_range(10.0, 60.0))
	var sizeVal : float = randf_range(8.0, 16.0)
	var newMesh = MeshInstance3D.new()
	add_child(newMesh)
	var baseType = int(randf_range(0.0,2.0))
	match(baseType):
		0:
			newMesh.mesh = BoxMesh.new() 
			isSquare = true
		1:
			newMesh.mesh = CylinderMesh.new()
			newMesh.mesh.radial_segments = 12
			newMesh.mesh.rings = 0
	#newMesh.mesh = CubeMesh.new()
	# newMesh.set_surface_material(0, buildMat)
	# Vary size
	newMesh.scale.x = sizeVal
	newMesh.scale.z = sizeVal
	newMesh.scale.y = buildingHeight
	$CollisionShape.shape.extents.y = buildingHeight/2
	$CollisionShape.shape.extents.x = sizeVal/1.6
	$CollisionShape.shape.extents.z = sizeVal/1.6
	$Area/CollisionShape.shape.extents.x = sizeVal/2
	$Area/CollisionShape.shape.extents.z = sizeVal/2
	newMesh.global_transform.origin.x = global_transform.origin.x
	newMesh.global_transform.origin.z = global_transform.origin.z
	newMesh.global_transform.origin.y = global_transform.origin.y + buildingHeight
	$CollisionShape.shape.extents.y =+ buildingHeight
	$Area.global_transform.origin.x = global_transform.origin.x
	$Area.global_transform.origin.z = global_transform.origin.z
	
	# Detail
	for i in range(0,buildingHeight/4.5):
		yOffset += 4.5
		var newWindow = MeshInstance3D.new()
		add_child(newWindow)
		newWindow.mesh = BoxMesh.new()
		newWindow.scale.y = 1.5
		if(i % 3 == 0):
			direction = int(randf_range(0.0,4.0))
		match direction:
			0:
				newWindow.global_transform.origin.x = global_transform.origin.x - newMesh.scale.x
				newWindow.global_transform.origin.z = global_transform.origin.z - newMesh.scale.z
			1:
				newWindow.global_transform.origin.x = global_transform.origin.x - newMesh.scale.x
				newWindow.global_transform.origin.z = global_transform.origin.z + newMesh.scale.z
			2:
				newWindow.global_transform.origin.x = global_transform.origin.x + newMesh.scale.x
				newWindow.global_transform.origin.z = global_transform.origin.z - newMesh.scale.z
			3:
				newWindow.global_transform.origin.x = global_transform.origin.x + newMesh.scale.x
				newWindow.global_transform.origin.z = global_transform.origin.z + newMesh.scale.z
		newWindow.global_transform.origin.y = yOffset
	
	# Top detail
	var newTopMesh = MeshInstance3D.new()
	add_child(newTopMesh)
	newTopMesh.mesh = BoxMesh.new()
	newTopMesh.scale.x = randf_range(3.0,newMesh.scale.x)
	newTopMesh.scale.z = randf_range(3.0,newMesh.scale.z)
	newTopMesh.scale.y = randf_range(1.0,12.0)
	newTopMesh.global_transform.origin.x = global_transform.origin.x
	newTopMesh.global_transform.origin.z = global_transform.origin.z
	newTopMesh.global_transform.origin.y = newMesh.scale.y + newTopMesh.scale.y
	
	for i in range(0,6):
		var genExtra = randf_range(0.0,1.0)
		if(genExtra > 0.5):
			var index = int(randi_range(0, details.size()))
			var newExtra = details[index].instance()
			add_child(newExtra)
			if(newExtra.is_in_group("Side")):
				newExtra.global_transform.origin = global_transform.origin
				newExtra.global_transform.origin.x -= newMesh.scale.x
				newExtra.rotation_degrees.y = randf_range(-180.0,180.0)
			elif(newExtra.is_in_group("Top")):
				newExtra.global_transform.origin = global_transform.origin
				newExtra.global_transform.origin.y = buildingHeight + 15.0

func _on_Area_body_entered(body):
	if(body != self):
		body.queue_free()
