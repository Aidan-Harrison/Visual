extends Node

# Chunk bounds (In metres)
var chunkXBounds : int = 100;
var chunkZBounds : int = 100;

# References
@onready var road1 = preload("res://Roads/CityGenRoad2.obj");

# Materials/Shaders
@onready var baseMat = preload("res://Extra/BaseMat.tres");

# Vegetation
@onready var treeMesh = preload("res://Assets/CityGenTrees.obj");
@onready var treeMesh2 = preload("res://Assets/CityGenTrees2.obj");
