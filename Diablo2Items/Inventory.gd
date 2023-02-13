extends ColorRect;

@onready var slot = preload("res://UI/InventoryButton.tscn");
@onready var blankIcon = preload("res://Assets/Textures/EmptyItemIcon.png");

var items = [];
var itemCount : int = -1;
const width : int = 8;
const height : int = 3;

func _ready():
	var offset : Vector2 = Vector2(125.0,100.0);
	for i in range(0, height):
		for j in range(0, width):
			var newSlot = slot.instantiate();
			add_child(newSlot);
			items.append(newSlot);
			newSlot.core.icon = blankIcon;
			newSlot.position = offset;
			offset.x += 100.0;
		offset.x = 125.0;
		offset.y += 225.0;

func _on_exit_pressed():
	visible = false;
