extends Node2D
@onready var clock = preload("res://assets/Levels/world1/clock_rigid_body.tscn")
@export var SpawnRange : float = 400.0
var CountClock : int = 0
@export var CountToClock : int = 9

@onready var Player = SaveGame.get_player()

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	spawn_clock()

func spawn_clock(SpawnAlways : bool = false) -> void:
	CountClock += 1
	#print(CountClock)
	if(CountClock % CountToClock == 0 || SpawnAlways):
		for child in get_children():
			if child is RigidBody2D:
				return
		if(clock):
			var clock_instance = clock.instantiate()
			add_child(clock_instance)
			clock_instance.global_position = global_position
			clock_instance.global_position.x = get_tree().get_nodes_in_group("Boss")[0].global_position.x if get_tree().get_nodes_in_group("Boss").size() else null
			clock_instance.get_node("Key").Despawn = true
