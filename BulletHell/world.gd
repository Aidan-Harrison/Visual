extends Node2D

var spawners = []
@onready var spawnMenu = $ContextMenu

func _ready():
	spawnMenu.visible = false
	for i in get_children():
		var nName : String = i.name # Have to convert as nodes use a seperate string data type with no 'contains()' function
		if(nName.contains('Spawner')):
			spawners.append(i)

func _input(event):
	if(Input.is_action_just_pressed('Reset')):
		get_tree().reload_current_scene()
	elif(Input.is_action_just_pressed('Pause')):
		if(get_tree().paused):
			get_tree().paused = false
		else:
			get_tree().paused = true
		for i in spawners:
			i.State()
			if(!i.paused):
				i.paused = true
			else:
				i.paused = false
