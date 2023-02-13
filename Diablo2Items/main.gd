extends Control;

# References
# === Item
@onready var itemBack  : ColorRect   = $ItemBack;
@onready var itemBackTexture         = $ItemBack/Texture;
@onready var itemName  : Label       = $ItemBack/ItemName;
@onready var iLevel    : Label       = $ItemBack/iLevel;
@onready var itemImage : TextureRect = $ItemBack/ItemIcon;
@onready var desc      : Label       = $ItemBack/Description;
@onready var cost      : Label       = $ItemBack/Value;
@onready var changeSymbol : Label    = $ItemBack/ChangeSymbol;
@onready var genCostLabel : Label    = $GENERATE/GenerationCost;
# === Item | Stats
@onready var values = $ItemBack/StatBack/ValueBack;
@onready var mods   = $ItemBack/StatBack/StatBack;
@onready var tiers  = $ItemBack/StatBack/TierBack;
# === Misc
@onready var hover = $Hover;
# === UI
@onready var menu       : ColorRect   = $MenuBack;
@onready var market     : ColorRect   = $MarketBack;
@onready var inventory  : ColorRect   = $InventoryBack;
@onready var lastProfit : Label       = $Background/Currency/LastProfit;
@onready var shortTermProfitLabel : Label  = $Background/Currency/ShortTermProft;
@onready var expLabel   : Label       = $Background/EXP;
@onready var expBar     : ProgressBar = $Background/EXP/EXPBar;
@onready var pLevel     : Label       = $Background/EXP/LEVEL;

# Generation
var item = null; # Foundation, used for storage
var itemRarity : int = 0;
var base       : int = 0;
var type       : int = 0;
var itemCost   : int = 100;
var maxCost    : int = 10000000; # 1 billion
var genCost    : int = 50;
var lastSellCost : int = 0;
var subsequentSellAmount : int = 0;
var subsequentSellReduction : int = 2;
var lockStates = [false,false,false,false,false,false]; # Specifies whether a mod can be changed, true = mod is locked

var curSet  : String = "";
var curItem : String = "";
var curType : String = "sword";

enum MODS{FIRST,SECOND,THIRD,FOURTH,FIFTH,SIXTH};

# Gameplay
@onready var currencyLabel : Label = $Background/Currency;
var lastSaleProfit : int = 0;
var shortTermProfit : int = 0;
# Crafting
@onready var agonyOrb       : Button = $Background/AgonyOrb;
@onready var turmoilCrystal : Button = $Background/TurmoilCrystal;
@onready var bismuthCrystal : Button = $Background/BismuthShard;
@onready var prism          : Button = $Background/Prism;
@onready var refinementJ    : Button = $Background/RefinementJewel;
@onready var exiled         : Button = $Background/ExiledOrb;
@onready var craftingItems = {"agony":agonyOrb, "turmoil":turmoilCrystal, "bismuth":bismuthCrystal, "prism":prism, "refinement":refinementJ, "exiled":exiled};

var numberOfCurrency = {
	"agony" : 5,
	"turmoil" : 3,
	"bismuth" : 3,
	"prism" : 1,
	"refinement" : 6,
	"exiled" : 1,
};
var currencyCost = {
	"agony" : 175,
	"turmoil" : 250,
	"bismuth" : 500,
	"prism" : 5000,
	"refinement" : 350,
	"exiled" : 7500,
};

#itemName.text = ItemData.base_1h_sword[randi_range(0, ItemData.base_1h_sword.size()-1)];
func _ready() -> void:
	iLevel.text = str(Profile.level);
	hover.visible = false;
	menu.visible = false;
	market.visible = false;
	inventory.visible = false;
	currencyLabel.text = str(Profile.bank);
	cost.text = str(itemCost);
	genCostLabel.text = str(genCost);
	lastProfit.text = str(lastSaleProfit);
	shortTermProfitLabel.text = str(shortTermProfit);
	expLabel.text = str(Profile.exp);
	expBar.value = 0; 
	expBar.max_value = Profile.nextLevel;
	pLevel.text = str(Profile.level);
	
	# === Currency setup ===
	for i in craftingItems.keys():
		craftingItems[i].get_node("Amount").text = "x" + str(numberOfCurrency[i]);
		craftingItems[i].get_node("COST").text = str(currencyCost[i]);
	
	Generate();
	
func _process(delta): 
	hover.position = get_global_mouse_position() + Vector2(125.0, 125.0);
	
func BuyCraftingItem(craftingItem : String) -> void:
	if(Transaction(currencyCost[craftingItem], false)):
		numberOfCurrency[craftingItem] += 1;
		craftingItems[craftingItem].get_node("Amount").text = "x" + str(numberOfCurrency[craftingItem]);
	
func SellCraftingItem(craftingItem : String) -> void:
	if(numberOfCurrency[craftingItem] <= 0):
		return;
	numberOfCurrency[craftingItem] -= 1;
	craftingItems[craftingItem].get_node("Amount").text = "x" + str(numberOfCurrency[craftingItem]);
	Transaction(currencyCost[craftingItem], true);
	
func UseCraftingItem(craftingItem : String) -> void:
	numberOfCurrency[craftingItem] -= 1;
	craftingItems[craftingItem].get_node("Amount").text = "x" + str(numberOfCurrency[craftingItem]);
	itemCost += currencyCost[craftingItem] * 0.25;
	cost.text = str(itemCost);

func ShimmerEffect(entity) -> void:
	if(!entity.has_node("Effect")):
		return;
	entity.get_node("Effect").visible = true;

func Transaction(amount : int, positive : bool) -> bool:
	if(positive):
		Profile.bank += amount;
		lastSellCost = amount; # Only apply if item sale
	else:
		if(Profile.bank - amount > 0):
			Profile.bank -= amount;
		else:
			return false;
	currencyLabel.text = str(Profile.bank);
	return true;
	
func ItemCostAdjustment(curValue : int, newValue : int) -> void:
	itemCost += newValue - subsequentSellReduction;
	if(itemCost > maxCost):
		itemCost = maxCost;
	elif(itemCost <= 1):
		itemCost = 1;
	cost.text = str(itemCost);
	
func RarityCheck(rarity : float, direct : bool = false, d_value : int = 0) -> void:
	var lastRarity = itemRarity;
	if(direct):
		match(d_value):
			0: 
				itemBack.color = Color.WEB_GRAY + Color(0.1, 0.1, 0.1);
				itemBackTexture.modulate = Color.WEB_GRAY;
			1: 
				itemBack.color = Color.CORNFLOWER_BLUE + Color(0.0, 0.0, 0.2);
				itemBackTexture.modulate = Color.CORNFLOWER_BLUE;
			2: 
				itemBack.color = Color.DARK_KHAKI + Color(0.2, 0.2, 0.0);
				itemBackTexture.modulate = Color.DARK_KHAKI;
			3: 
				itemBack.color = Color.LIGHT_SALMON;
				itemBackTexture.modulate = Color.LIGHT_SALMON;
		return;
	if(rarity < 50):
		itemBack.color = Color.WEB_GRAY + Color(0.1, 0.1, 0.1);
		itemBackTexture.modulate = Color.WEB_GRAY;
		itemRarity = 0;
		if(itemRarity < lastRarity):
			ItemCostAdjustment(itemCost, -itemCost * 0.1);
	elif(rarity > 50 && rarity < 75):
		itemRarity = 1;
		itemBack.color = Color.CORNFLOWER_BLUE + Color(0.0, 0.0, 0.2);
		itemBackTexture.modulate = Color.CORNFLOWER_BLUE;
		if(itemRarity > lastRarity):
			ItemCostAdjustment(itemCost, itemCost * 0.25);
		else:
			ItemCostAdjustment(itemCost, -itemCost * 0.2);
	elif(rarity > 75 && rarity < 99):
		itemRarity = 2;
		itemBack.color = Color.DARK_KHAKI + Color(0.2, 0.2, 0.0);
		itemBackTexture.modulate = Color.DARK_KHAKI;
		if(itemRarity > lastRarity):
			ItemCostAdjustment(itemCost, itemCost * 0.5);
		else:
			ItemCostAdjustment(itemCost, -itemCost * 0.45);
	elif(rarity > 99):
		itemRarity = 3;
		itemBack.color = Color.LIGHT_SALMON;
		itemBackTexture.modulate = Color.LIGHT_SALMON;
		if(itemRarity > lastRarity):
			ItemCostAdjustment(itemCost, itemCost*itemCost);
		else:
			ItemCostAdjustment(itemCost, -itemCost*itemCost);

func RollStats(start : int = 0, end : int = 6) -> void: # Rolls specified stats
	var generatedMods = [];
	var prefixIndex : int = 0; # Stores prefix for value and tier calculation
	for i in range(start, end):
		if(lockStates[i]):
			continue;
		match(i):
		# === STATS | Implicits ===
			MODS.FIRST: match(type):
				0: mods.get_node("S1").text = ItemData.weapon_implicits[curItem][0];
				1: mods.get_node("S1").text = ItemData.armor_implicits[curItem][0];
			MODS.SECOND: match(type):
				0: mods.get_node("S2").text = ItemData.weapon_implicits[curItem][1];
				1: mods.get_node("S2").text = ItemData.armor_implicits[curItem][1];
		# === STATS | Prefixes ===
			MODS.THIRD:
				match(type):
					0: mods.get_node("S3").text = ItemData.weapon_prefixes[curType][randi_range(0, ItemData.weapon_prefixes[curType].size()-1)];
					1: mods.get_node("S3").text = ItemData.armor_prefixes[curType][randi_range(0, ItemData.armor_prefixes[curType].size()-1)];
			MODS.FOURTH:
				mods.get_node("S4").text = mods.get_node("S3").text;
				match(type):
					0:
						while(mods.get_node("S4").text == mods.get_node("S3").text):
							mods.get_node("S4").text = ItemData.weapon_prefixes[curType][randi_range(0, ItemData.weapon_prefixes[curType].size()-1)];
					1:
						while(mods.get_node("S4").text == mods.get_node("S3").text):
							mods.get_node("S4").text = ItemData.armor_prefixes[curSet][randi_range(0, ItemData.armor_prefixes[curSet].size()-1)];
		# === STATS | Suffixes ===
			MODS.FIFTH:
				match(type):
					0:
						mods.get_node("S5").text = ItemData.weapon_suffixes[randi_range(0, ItemData.weapon_suffixes.size()-1)];
						mods.get_node("S6").text = mods.get_node("S5").text;
						while(mods.get_node("S6").text == mods.get_node("S5").text):
							mods.get_node("S6").text = ItemData.weapon_suffixes[randi_range(0, ItemData.weapon_suffixes.size()-1)];
					1:
						mods.get_node("S5").text = ItemData.armor_suffixes[randi_range(0, ItemData.armor_suffixes.size()-1)];
						mods.get_node("S6").text = mods.get_node("S5").text;
						while(mods.get_node("S6").text == mods.get_node("S5").text):
							mods.get_node("S6").text = ItemData.armor_suffixes[randi_range(0, ItemData.armor_suffixes.size()-1)];
			MODS.SIXTH:
				mods.get_node("S6").text = mods.get_node("S5").text;
				match(type):
					0:
						while(mods.get_node("S6").text == mods.get_node("S5").text):
							mods.get_node("S6").text = ItemData.weapon_suffixes[randi_range(0, ItemData.weapon_suffixes.size()-1)];
					1:
						while(mods.get_node("S6").text == mods.get_node("S5").text):
							mods.get_node("S6").text = ItemData.armor_suffixes[randi_range(0, ItemData.armor_suffixes.size()-1)];
		# === VALUES ===
		match(type):
			0:
				#var rolledValue : int = ItemData.weapon_prefixes_values[curType][randi_range(0, ItemData.weapon_prefixes_values[curType][ItemData.weapon_prefixes_values.size()-1])];
				values.get_child(i).text = str(randi_range(1, 100)); 
			1:
				pass
				#values.get_child(i).text = ItemData.weapon_prefixes_values[curType][randi_range(0, ItemData.weapon_prefixes_values[ItemData.weapon_prefixes_values.size()-1])];
	# === TIERS ===
	for i in tiers.get_children():
		match(type):
			0:
				pass
		i.text = str(5);
	# === DESCRIPTION ===
	match(type):
		0:
			desc.text = ItemData.weapon_descriptions[curItem];
		1:
			pass

func Generate() -> void:
	iLevel.text = str(Profile.level); # Continue V
	
	genCost += genCost*0.10+lastSellCost*0.5;
	print("New: ", genCost, " Last sell cost: ", lastSellCost);
	genCostLabel.text = str(genCost);
	curSet = "";
	curItem = ""; # Name
	curType = "sword"; # Used to determine prefixes, suffixes and crafting
	var itemRarity : int = 0;
	type = randi_range(0, 1); # Defines: WEAPON | ARMOR | ACCESSORY
	var rarity : float = randi_range(0, 100);
	RarityCheck(rarity);
	# === BASE ===
	match(type): # Generate base
		0: base = randi_range(0, ItemData.weapons.size()-1);
		1: base = randi_range(0, ItemData.armor.size()-1);
	match(type): # Match appropiate base to type
		0: # | WEAPON
			match(base):
				0: 
					curSet = "base_1h_sword";
				1: 
					curSet = "base_2h_sword";
				2: 
					curSet = "base_dagger";
					curType = "dagger";
				3: 
					curSet = "base_1h_blunt";
					curType = "blunt";
				4: 
					curSet = "base_2h_blunt";
					curType = "blunt";
		1: # | ARMOR
			match(base):
				0:
					curSet = "helmet";
					curType = "helmet";
				1:
					curSet = "chest";
					curType = "chest";
				2:
					curSet = "belt";
					curType = "belt";
	match(type):
		0: curItem = ItemData.weapons[curSet][randi_range(0, ItemData.weapons[curSet].size()-1)];
		1: curItem = ItemData.armor[curSet][randi_range(0, ItemData.armor[curSet].size()-1)];
	RollStats();
	
	# === Prefix and Suffix name generation ===
	var chance : float = randf_range(0.0, 1.0);
	if(chance > 0.9):
		# Fix, insert function doesn't work
		curItem.insert(0, ItemData.name_prefixes[randi_range(0, ItemData.name_prefixes.size()-1)] + " ");
	if(chance > 0.925):
		curItem += " " + ItemData.name_suffixes[randi_range(0, ItemData.name_suffixes.size()-1)];
	itemName.text = curItem;

# Crafting Items
func AgonyOrb() -> void: # Re-rolls everything
	RollStats();

# Re-rolls a single random mod
func TurmoilCrystal() -> void:
	var mod : int = randi_range(0, 6);
	RollStats(mod, mod);
	
# Selects a random stat to roll one tier higher, but changes stat
# If no stats can be rolled higher, simple re-roll a given stat and keep the tier
func RefinementJewel() -> void:
	var mod : int = randi_range(0, 6);
	RollStats(mod,mod);
	tiers.get_child(mod).text = str(int(tiers.get_child(mod).text)+1);
	
func BismuthShard() -> void: # Upgrades rarity, cannot do rare -> unique. If already rare not applicable, grey out
	itemRarity += 1;
	RarityCheck(0.0, true, itemRarity);

# Special | Foils item
func Prism() -> void:
	pass

# Locks a random mod of an item, preventing it from being changed
func ExiledOrb() -> void:
	var mod : int = randi_range(0, 6);
	while(lockStates[mod]):
		mod = randi_range(0, 6);
	lockStates[mod] = true;
	
func _on_generate_pressed():
	if(Transaction(genCost, false)):
		Generate();
		subsequentSellAmount = 0;

# Hover functions | Refactor to single mouse code!
func _on_agony_orb_mouse_entered(): 
	hover.visible = true;
	hover.text = "Re-rolls everything";
func _on_agony_orb_mouse_exited(): hover.visible = false;

func _on_menu_pressed():
	if(menu.visible):
		menu.visible = false;
	else:
		menu.visible = true;

func _on_exit_pressed():
	menu.visible = false;

func _on_market_pressed():
	if(market.visible):
		market.visible = false;
	else:
		market.visible = true;

func _on_marketexit_pressed():
	market.visible = false;

func _on_itemsell_pressed():
	Transaction(itemCost, true);
	Generate();
	if(Profile.AddExp(itemCost * 0.25)):
		expBar.max_value = Profile.nextLevel;
		pLevel.text = str(Profile.level);
	expLabel.text = str(Profile.exp);
	expBar.value = Profile.exp;
	if(subsequentSellAmount < 12):
		subsequentSellReduction += subsequentSellReduction * 0.5;
		subsequentSellAmount += 1;
		print(subsequentSellReduction);

func _on_inventory_pressed():
	inventory.visible = true;

func _on_itemstore_pressed():
	if(inventory.itemCount < inventory.items.size()):
		inventory.itemCount += 1;
		inventory[inventory.itemCount];

# === Crafting Items ===
func _on_agony_orb_pressed():
	if(numberOfCurrency["agony"] < 1):
		return;
	AgonyOrb();
	UseCraftingItem("agony");
	
func _on_turmoil_crystal_pressed():
	TurmoilCrystal();
	UseCraftingItem("turmoil");
	
func _on_bismuth_shard_pressed():
	if(itemRarity < 2):
		UseCraftingItem("bismuth");
	BismuthShard();
	
func _on_exiled_orb_pressed():
	ExiledOrb();
	UseCraftingItem("exiled");

# === Crafting Items | BUY/SELL ===
func _on_buy_pressed():
	BuyCraftingItem("agony");
func _on_sell_pressed():
	SellCraftingItem("agony");
func _on_turm_buy_pressed():
	BuyCraftingItem("turmoil");
func _on_turm_sell_pressed():
	SellCraftingItem("turmoil");
func _on_bis_buy_pressed():
	BuyCraftingItem("bismuth");
func _on_bis_sell_pressed():
	SellCraftingItem("bismuth");
func _on_pri_buy_pressed():
	BuyCraftingItem("prism");
func _on_pri_sell_pressed():
	SellCraftingItem("prism");
func _on_ref_buy_pressed():
	BuyCraftingItem("refinement");
func _on_ref_sell_pressed():
	SellCraftingItem("refinement");
func _on_exi_buy_pressed():
	BuyCraftingItem("exiled");
func _on_exi_sell_pressed():
	SellCraftingItem("exiled");

func _on_restart_pressed():
	get_tree().reload_current_scene();

# Adjust item price based on market
func _on_market_back_current_market_state(marketState, lastValue, variation):
	for i in marketState.keys():
		if(curType == i):
			itemCost += variation;
			cost.text = str(itemCost);
			if(variation > lastValue):
				cost.modulate = Color.FOREST_GREEN;
				changeSymbol.text = "^";
				changeSymbol.modulate = Color.FOREST_GREEN;
			elif(variation < lastValue):
				cost.modulate = Color.DARK_RED;
				changeSymbol.text = "V";
				changeSymbol.modulate = Color.DARK_RED;
			else:
				cost.modulate = Color.LIGHT_SALMON;
				changeSymbol.text = "~";
				changeSymbol.modulate = Color.LIGHT_SALMON;
