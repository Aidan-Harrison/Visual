extends RigidBody3D

var points = [];
var marked = [];
var resolution : int = 16; # Change how this works! DON'T ALTER SIZE
var vSize : Vector3 = Vector3.ZERO;

var pMaskTx : int = 1;
var pMaskTy : int = 1;
var pMaskBx : int = 1;
var pMaskBy : int = 1;
var propagate : int = 0;

@onready var particles : GPUParticles3D = $Particles;

func _ready():
	pass
	
func CheckStates() -> bool:
	for i in marked:
		if(!i):
			return false;
	return true;

func Activate():
	particles.emitting = true;
	# $ColCheck.start(); # Attempt!
	var counter : int = 0;
	while(counter < 3):
		# Do fill algorithm | 2D for now
		if(pMaskTx > 0 && pMaskTy > 0):
			pMaskTx -= 1;
			pMaskTy -= 1;
		if(pMaskBx < vSize.x && pMaskBy < vSize.y):
			pMaskBx += 1;
			pMaskBy += 1;
		# Iterate over mask
		for i in range(pMaskTx, pMaskBx):
			for j in range(pMaskTy, pMaskBy):
				var children = points[i].get_children(); # Optimise! Use deferred f call
				children[i+j*vSize.x];
				if(!marked[i+j*vSize.x]):
					marked[i+j*vSize.x] = true;
					# Combine be deleting and expanding
					children[0].scale.x = propagate; # Calculate appropiate directions as propogation happens
					children[1].shape.size.x = propagate;
					points[i+j*vSize.y].sleeping = false;
					points[i+j*vSize.y].freeze = false;
		counter+=1;
		# Collision

func generate(size : Vector3, colour : StandardMaterial3D):
	vSize.x = size.x/10;
	vSize.y = size.y/10;
	vSize.z = size.z/10;
	particles.process_material.emission_box_extents.x = size.x;
	particles.process_material.emission_box_extents.y = size.y;
	# Positonal and ID data, used for casting
	
	
	#particles.draw_pass_1.material = colour; # Fix!, assigning to all
	var spatialIterator : Vector3 = Vector3.ZERO;
	for i in range(0, resolution):
		var newSubVoxel : RigidBody3D = RigidBody3D.new();
		add_child(newSubVoxel);
		points.append(newSubVoxel);
		marked.append(false);
		newSubVoxel.sleeping = true;
		newSubVoxel.freeze = true;
		var subMesh : MeshInstance3D = MeshInstance3D.new();
		newSubVoxel.add_child(subMesh);
		subMesh.mesh = BoxMesh.new();
		subMesh.mesh.material = colour;
		subMesh.scale = vSize;
		var subCol : CollisionShape3D = CollisionShape3D.new();
		newSubVoxel.add_child(subCol);
		subCol.shape = BoxShape3D.new();
		subCol.disabled = false;
		subCol.shape.size = vSize;
		# Timer | Used to stop calculations after x amount of time after ground collision
		var newTimer : Timer = Timer.new();
		newSubVoxel.add_child(newTimer);
		# Position
		newSubVoxel.position = spatialIterator;
		spatialIterator.x += vSize.x;
		if(spatialIterator.x >= vSize.x * resolution/2):
			spatialIterator.x = 0;
			spatialIterator.z += vSize.z;
		if(spatialIterator.z >= vSize.z * resolution/2):
			spatialIterator.z = 0;
			spatialIterator.y += vSize.y;

func _on_voxel_body_entered(body):
	if(body.is_in_group("Projectile")):
		pass

func _on_col_check_timeout():
	for i in points:
		pass
