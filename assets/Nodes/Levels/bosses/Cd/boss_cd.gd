extends CharacterBody2D

var Speed : Vector2 = Vector2(0.0, 0.0)
const MaxSpeed : Vector2 = Vector2(200.0, 100.0)
const Acc : Vector2 = Vector2(140.0, 120.0) 
const ChangeDirXVel : float = 30.0

var MovingDir : Vector2 = Vector2(1.0, 0.0)

@onready var Player = SaveGame.get_player()

func _calc_player_dir() -> float:
	return ceil(clamp(Player.global_position.x - global_position.x, -1.0, 1.0))

func _physics_process(delta: float) -> void:
	MovingDir.x = _calc_player_dir()
	
	if(MovingDir.x):
		if(ceil(clamp(Speed.x, -1.0, 1.0) ) != MovingDir.x): Speed.x = lerpf(Speed.x, MovingDir.x, ChangeDirXVel*delta)
		if(abs(Speed.x) < abs(MaxSpeed.x)):
			Speed.x += Acc.x * MovingDir.x * delta
	else:
		Speed.x = lerpf(Speed.x, 0.0, Acc.x*delta)
	
	velocity = Speed
	print(velocity)
	move_and_slide()
