extends Node2D

@export var scenes = ["res://assets/Levels/world1/menu_level9.tscn"]

func _ready() -> void:
	var LoadedScene = scenes[randi() % scenes.size()]
	var PackedScene = load(LoadedScene)
	
	var scene_instance = PackedScene.instantiate()
	add_child(scene_instance)
