extends Node2D
@onready var clock = preload("res://assets/Nodes/Obj/Gameplay/Boss/Slimo/clock_rigid_body.tscn")
@onready var bomb = preload("res://assets/Nodes/Obj/Gameplay/Boss/Slimo/BossBomb.tscn")
@export var SpawnRange : float = 400.0
var CountClock : int = 0
@export var CountToClock : int = 9

@onready var Player = SaveGame.get_player()

var Phase2 : bool = false 

func spawn_bomb(MoveToPlayer : bool = true, Pos : Vector2  = Vector2(0.0,0.0)) -> void:
	#for child in get_children():
	#	if child.is_in_group("BossBomb"):
	#		return
	if(clock):
		var bomb_instance = bomb.instantiate()
		add_child(bomb_instance)
		bomb_instance.Phase2 = Phase2
		if(MoveToPlayer): bomb_instance.global_position = Player.global_position
		else: bomb_instance.global_position = Pos
		#bomb_instance.global_position = global_position
		#bomb_instance.global_position.x = get_tree().get_nodes_in_group("Boss")[0].global_position.x if get_tree().get_nodes_in_group("Boss").size() else Vector2(0.0,0.0)

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
			clock_instance.global_position.x = get_tree().get_nodes_in_group("Boss")[0].global_position.x if get_tree().get_nodes_in_group("Boss").size() else Vector2(0.0,0.0)
			clock_instance.get_node("Key").Despawn = true
