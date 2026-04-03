extends RigidBody2D

var Destroy : bool = true

var linear_jump_y : float = -100.0
@export var CollisionShape : CollisionShape2D 
@onready var Player = SaveGame.get_player()

func _process(delta: float) -> void:
#	print("Distance y: " + str(Player.global_position.y - global_position.y))
#	print("Distance y: " + str(Player.global_position.x - global_position.x))
	set_collision_layer_value(9, Player.global_position.y < global_position.y-20)# || abs(Player.global_position.x - global_position.x) > 120)
	if(abs(linear_jump_y) > 10):
		linear_jump_y = lerp(linear_jump_y, 0.0, 5*delta)

func _integrate_forces(state):
	var velocity = state.linear_velocity
	var speed = velocity.length()
	if(abs(linear_jump_y) > 10):
		state.linear_velocity.y = linear_jump_y
