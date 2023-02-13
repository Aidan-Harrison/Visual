extends Node;
# ==== Weapons bases ====
var weapons = {
	"base_1h_sword" : ["Silver Sword", "Short Sword", "Rapier", "Cutlass", "Long Sword"], 
	"base_2h_sword" : ["Claymore", "Two-Handed Sword", "Washing Pole", "Zweihandler"], 
	"base_dagger"   : ["Rouge Dagger", "Serrated Dagger", "Shank", "Gut Knife"], 
	"base_1h_blunt" : ["Blacksmith Hammer", "Mace", "Club"], 
	"base_2h_blunt" : ["Warhammer", "Granite Maul"], 
};
# ==== Weapon Implicits ====
var weapon_implicits = {
	# === 1H SWORDS ===
	"Silver Sword" : ["physical damage", "Convert 25% physical to magic damage"],
	"Short Sword"  : ["crtical damage", "attack speed"],
	"Rapier"       : ["DEX", "critical chance"],
	"Cutlass"      : ["bleed damage", "bleed chance"],
	"Long Sword"   : ["physical damage", "DEX"],
	# === 2H SWORDS ===
	"Claymore"         : ["physical damage", "STR"],
	"Two-Handed Sword" : ["physical damage", "critical damage"],
	"Washing Pole"     : ["attack range", "attack speed"],
	"Zweihandler"      : ["health", "STR"],
	# === DAGGERS ===
	"Rouge Dagger"    : ["critical strike chance", "crtical strike damage"],
	"Serrated Dagger" : ["bleed damage", "bleed chance"],
	"Shank"           : ["pierce", "attack speed"],
	"Gut Knife"       : ["crit & bleed damage", "pierce"],
	# === 1H BLUNT ===
	"Blacksmith Hammer" : ["penertration", "stun chance"],
	"Mace"              : ["physical damage", "stun damage"],
	"Club"              : ["stun chance", "stun damage"],
	# === 2H BLUNT ===
	"Warhammer"    : ["health", "STR"],
	"Granite Maul" : ["STR", "damage per {} STR"],
};

# === Weapon prefixes ===
var weapon_prefixes = {
	"sword"  : ["physical damage", "pierce", "penetration"],
	"dagger" : ["DEX", "critical strike chance", "critical strike damage"],
	"blunt"  : ["STR", "physical damage", "stun chance"],
};
var weapon_prefixes_values = { # Also tiers, range is first and last
	"sword" : [[11,22,36,40,46],[16,18,22,28,32],[]],
	"dagger": [[],[],[]],
	"blunt" : [[],[],[]],
};
var weapon_suffixes = [
	"STR","DEX","INT",
];
var weapon_descriptions = {
	"Silver Sword" : "A simple silver sword, used by the common knight",
	"Short Sword"  : "A sword typically used for training",
	"Rapier"       : "Sharp, precise, deadly",
	"Cutlass"      : "Cut through the strongest of surfaces for your goal",
	"Long Sword"   : "A common knight sword",
	# === 2H SWORDS ===
	"Claymore"         : "Weight is a weapon",
	"Two-Handed Sword" : "A common knight guard sword for the",
	"Washing Pole"     : "Much too long to be wielded",
	"Zweihandler"      : "A towering blade capable of cleaving armies",
	# === DAGGERS ===
	"Rouge Dagger"    : "A thief's trustiest tool",
	"Serrated Dagger" : "Swift violence works wonders",
	"Shank"           : "Crude yet effective",
	"Gut Knife"       : "Brtuallity at its finest",
	# === 1H BLUNT ===
	"Blacksmith Hammer" : "A trusty hammer goes a long way",
	"Mace"              : "Simple yet brutal",
	"Club"              : "As crude as it comes yet fear inducing",
	# === 2H BLUNT ===
	"Warhammer"    : "Only the strongest of armor can withstand a blow from this",
	"Granite Maul" : "Earth shattering strength is needed to weild this behemoth",
};
# ==== Armor bases ====
var armor = {
	"helmet" : ["Coif", "Knight Helmet", "Royal Helmet", "Gladiator Mask", "Paladin Helm"],
	"chest"  : ["Garb", "Gladiator Plate", "Paladins Chestpiece", "Robes", "Ragged Shirt"],
	"belt"   : ["Leather Belt", "Chain Belt", "Silk Sash"],
};
var armor_implicits = {
	# === HELMET ===
	"Coif"           : ["Evasion rating", "Movement speed"],
	"Knight Helmet"  : ["Armor", "Health"],
	"Royal Helmet"   : ["Gold find", "Health"],
	"Gladiator Mask" : ["STR", "Bleed resistance"],
	"Paladin Helm"   : ["Holy rating", "Holy resistance"],
	# === CHEST ===
	"Garb"                : ["Mana", "Mana efficiency"],
	"Gladiator Plate"     : ["STR", "Armor"],
	"Paladins Chestpiece" : ["Holy rating", "Holy resistance"],
	"Robes"               : ["DEX", "INT"],
	"Ragged Shirt"        : ["Evasion rating", "Movement speed"],
	# === BELT ===
	"Leather Belt" : ["STR", "Health"],
	"Chain Belt"   : ["DEX", "Evasion Rating"],
	"Silk Sash"    : ["Mana", "INT"],
};
var armor_prefixes = {
	"helmet" : ["%  of items found", "reflected back to attackers"],
	"chest"  : ["To maximum life", "% reflected back to attackers", "stun & block recovery"],
	"belt"   : ["To maximum life", "Life regeneration", "Armor"],
};
var armor_suffixes = [
	" armor", "STR", "Fire resistance", "Cold resistance", "Lightning resistance",
];

# Name prefixes and suffixes
var name_prefixes = [
	"Prestine",
	"Perfect",
	"Flawless",
	"Refined",
	"Crafted",
];
var name_suffixes = [
	"of Lothric",
	"of Limbo",
	"of the Void",
];
