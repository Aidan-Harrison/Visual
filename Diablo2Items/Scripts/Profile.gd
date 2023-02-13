extends Node;

var level : int = 1;
var exp   : int = 0;
var nextLevel : int = 250;
var maxLevel : int = 99;
var bank  : int = 1000;

var inventory = [];

# User interaction
var hasItem : bool = false;
var curItem = null;

func AddExp(amount : int) -> bool:
	exp += amount;
	if(exp >= nextLevel):
		var carryAmount : int = exp - nextLevel;
		level += 1;
		nextLevel += nextLevel * 0.5;
		exp = carryAmount;
		return true;
	return false;
