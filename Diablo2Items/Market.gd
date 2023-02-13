extends ColorRect;

@onready var item = preload("res://UI/MarketItem.tscn");
var canStock : bool = false;

# Market sim
@onready var one_h_sword : ProgressBar = $DemandBack/one_h_sword;
@onready var two_h_sword : ProgressBar = $DemandBack/two_h_sword;
@onready var dagger      : ProgressBar = $DemandBack/dagger;
@onready var one_h_blunt : ProgressBar = $DemandBack/one_h_blunt;
@onready var two_h_blunt : ProgressBar = $DemandBack/two_hand_blunt;
	# Market | Demand (Aritary)
var markets = {
	"base_1h_sword" : 10,
	"base_2h_sword" : 10,
	"base_dagger"   : 10,
	"base_1h_blunt" : 10,
	"base_2h_blunt" : 10,
};
@onready var chart = [one_h_sword, two_h_sword, dagger, one_h_blunt, two_h_blunt];
# ==========

signal alterprice(marketState);
signal currentMarketState(marketState, lastValue, variation);

func _ready():
	# Assign colors
	var color : Color = Color.RED;
	for bar in chart:
		bar.modulate = color;
		color.r -= 10;
		color.b += 10;
	Stock();

func Stock() -> void:
	canStock = false;
	#for i in 10:
		#var newItem = item.instantiate();
		#list.add_child(newItem);

func _on_refresh_pressed():
	if(canStock):
		Stock();

func _on_shop_timer_timeout():
	canStock = true;

# === Market simulation ===
func Tick() -> void:
	var index : int = 0;
	var variation : int = 0;
	for i in markets.keys():
		var last : int = variation;
		variation = randi_range(-6, 6);
		if(markets[i] + variation <= 0):
			markets[i] = 1;
		markets[i] += variation;
		chart[index].value = markets[i];
		#chart[index].value = lerp(chart[index].value, markets[i], 0.1);
		index+=1;
		emit_signal("currentMarketState", markets, last, variation);
	#emit_signal("alterprice", markets);

func _on_tick_rate_timeout():
	Tick();
