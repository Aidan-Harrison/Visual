extends Control;

@onready var sold = $Sold;
@onready var buy = $ColorRect/BUY;

var item = null;

func AssignItem() -> void:
	pass;

func _ready():
	sold.visible = false;

func _on_buy_pressed():
	sold.visible = true;
	buy.disabled = true;
	Profile.inventory.append(item);
