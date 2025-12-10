extends Node2D
@onready var clock = preload("res://assets/Levels/world1/clock_rigid_body.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_clock()

func spawn_clock() -> void:
	if(clock):
		var clock_instance = clock.instantiate()
		add_child(clock_instance)
		clock_instance.global_position = global_position
