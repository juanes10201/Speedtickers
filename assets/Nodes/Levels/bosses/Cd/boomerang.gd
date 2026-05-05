extends Area2D

var Enabled : bool = false
enum States{
	Initial = 1,
	Back = -1
}
var State = States.Initial

@export var ChangeTime : Timer
@export var Boss : Node2D

const Speed : float = 500.0

var Direction : int = 1.0

func enable() -> void:
	ChangeTime.start()
	State = States.Initial
	Enabled = true
	global_position = Boss.global_position
	Direction = Boss.MovingDir.x

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Enabled):
		if(State == States.Initial):
			position.x += delta * Speed * State * Direction
		else:
			global_position = lerp(global_position, Boss.global_position, Speed*delta)

func _on_timer_timeout() -> void:
	State *= -1
