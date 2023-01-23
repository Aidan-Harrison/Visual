extends Node3D

@onready var mesh = $MultiMeshInstance;
@onready var col = $CollisionShape3d;

var colours = [Color.AQUA,Color.REBECCA_PURPLE,Color.RED,Color.CHARTREUSE,Color.DARK_ORANGE];
var cars = [];

func _ready():
	col.shape.size = Vector3(GlobalSettings.chunkXBounds*0.85, 10.0, GlobalSettings.chunkZBounds*0.85);
	col.position = Vector3(GlobalSettings.chunkXBounds/2, 0.0, GlobalSettings.chunkZBounds/2);
	
	# Light generation
#	var chance = randf_range(0.0, 1.0);
#	if(chance > 0.7):
#		var newLight : OmniLight3D = OmniLight3D.new();
#		add_child(newLight);
#		newLight.omni_range = GlobalSettings.chunkXBounds*3;
#		newLight.light_energy = 200.0;
#		newLight.position = Vector3(GlobalSettings.chunkXBounds/2, 25.0, GlobalSettings.chunkZBounds/2);
#		newLight.light_color = Color.BLANCHED_ALMOND;

	#colours.append(Color.AQUA);
#	colours.append(Color.REBECCA_PURPLE);
#	colours.append(Color.RED);
#	colours.append(Color.CHARTREUSE);
#	colours.append(Color.DARK_ORANGE);
	generator();

func generator():
	var xPos : int = 0;
	var zPos : int = 0;
	for i in range(0, mesh.multimesh.get_instance_count()):
		var xCol = false;
		var zCol = false;
		var height : int = int(randf_range(2.0,5.0)); #???
		#var index : int = int(randi_range(0.0,colours.size()))
		xPos = int(randi_range(0.0, GlobalSettings.chunkXBounds));
		zPos = int(randi_range(0.0, GlobalSettings.chunkZBounds));
#		xPositions.append(xCount);
#		zPositions.append(zCount);
#		for j in range(0, xPositions.size()-1):
#			if(xPositions[j] < xCount + 10 && xPositions[j] + 10 > xCount):
#				xCol = true
#				break
#		for k in range(0, zPositions.size()-1):
#			if(zPositions[k] < zCount + 10 && zPositions[k] + 10 > zCount):
#				zCol = true
#				break
#		if(xCol && zCol):
#			continue
		mesh.multimesh.set_instance_transform(i, Transform3D(Vector3(1.5,0.0,0.0), Vector3(0.0,height,0.0), Vector3(0.0,0.0,1.5), Vector3(xPos,0.0,zPos)));
		# Do rotation
