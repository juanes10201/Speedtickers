extends CharacterBody2D

var Speed : Vector2 = Vector2(0.0, 0.0)
const MaxSpeed : Vector2 = Vector2(300.0, 100.0)
const Acc : Vector2 = Vector2(200.0, 120.0) 
const ChangeDirXVel : float = 30.0
const RadiusJump : float = 100.0

var MovingDir : Vector2 = Vector2(1.0, 0.0)

@export_subgroup("Jump")
@export_range(0, 7000.0, .5, "or_greater", "or_less") var WallJumpVelocity : float = 7000.0
@export_range(0, 100, .5, "or_greater", "or_less") var jump_height : float = 70.0
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_peak : float = 0.5
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_descent : float = 0.4

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var Player = SaveGame.get_player()

var Jumped : bool = false

func _calc_player_dir() -> float:
	return ceil(clamp(Player.global_position.x - global_position.x, -1.0, 1.0))

func _movement_x(delta : float) -> void:
	MovingDir.x = _calc_player_dir()
	
	if(MovingDir.x):
		if(ceil(clamp(Speed.x, -1.0, 1.0) ) != MovingDir.x): Speed.x = lerpf(Speed.x, MovingDir.x, ChangeDirXVel*delta)
		if(abs(Speed.x) < abs(MaxSpeed.x)):
			Speed.x += Acc.x * MovingDir.x * delta
	else:
		Speed.x = lerpf(Speed.x, 0.0, Acc.x*delta)

func _movement_y(delta : float) -> void:
	if(is_on_floor()): Jumped = false
	if(!Jumped && global_position.distance_to(Player.global_position) <= RadiusJump): 
		Jumped = true
		velocity.y = jump_velocity
	velocity.y += get_gravity_player() * delta

func get_gravity_player() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _physics_process(delta: float) -> void:
	_movement_x(delta)
	_movement_y(delta)
	
	velocity.x = Speed.x
	print(velocity)
	move_and_slide()
