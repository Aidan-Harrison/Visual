extends ColorRect;

var curItem = null;
@onready var core : Button = $Core;

func _ready() -> void:
	pass;

func _on_color_rect_pressed():
	if(curItem == null && Profile.hasItem):
		curItem = Profile.curItem;
		Profile.curItem = null;
		Profile.hasItem = false;
		Profile.inventory.append(curItem);
	else:
		Profile.curItem = curItem;
		Profile.inventory.erase(Profile.inventory.find(curItem));
		Profile.hasItem = true;
		curItem = null;
