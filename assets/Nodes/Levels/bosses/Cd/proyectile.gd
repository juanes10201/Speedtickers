extends Area2D

var velocity : Vector2 = Vector2(0.0, 0.0)
const acc : float = 10.0
const max_vel : Vector2 = Vector2(100.0, 100.0) 

@onready var OriginalPos : Vector2 = global_position
@export var TimerInitialFly : Timer
@onready var Player = SaveGame.get_player()
var GoToPos : Vector2 = Vector2(0.0, 0.0)

var initial_dir : float = 0.0

func _ready() -> void:
	TimerInitialFly.start()
	initial_dir = ceil(clamp(global_position.x-Player.global_position.x, -1.0, 1.0))

func _process(delta: float) -> void:
	if(velocity.x <= max_vel.x): velocity.x += acc
	
	if(TimerInitialFly.is_stopped()):
		position.x = lerpf(position.x, GoToPos.x, acc*delta)
		position.y = lerpf(position.y, GoToPos.y, acc*delta)
	else:
		velocity.y -= acc*initial_dir*delta
		velocity.x += acc/2*initial_dir*delta
		position += velocity


func _on_timer_initial_fly_timeout() -> void:
	GoToPos = Player.global_position
