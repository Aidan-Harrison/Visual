extends Node

# Chunk bounds (In metres)
var chunkXBounds : int = 100;
var chunkZBounds : int = 100;

# Temp?
var WIDTH : int = 6; # Might not need to keep!
var HEIGHT : int = 6;

# References
@onready var road1 = preload("res://Roads/CityGenRoad2.obj");
