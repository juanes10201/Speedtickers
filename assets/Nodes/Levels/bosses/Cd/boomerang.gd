extends Area2D

var Enabled : bool = false
enum States{
	Initial = 1,
	Back = -1
}
var State = States.Initial

@export var ChangeTime : Timer
@export var Boss : Node2D

var Speed : float = 0.0
const Acc : float = 800.0
const InitialSpeed : float = 500.0
const SpeedDelta : float = 3.0
var Direction : int = 1.0
@onready var Sprite = $Sprite2D2
@onready var Player = SaveGame.get_player()  
@export var AudioAttackBoomerang : AudioStreamPlayer
@export var AudioAttackBack : AudioStreamPlayer

func disable() -> void:
	State = States.Initial
	Enabled = false
	global_position = Boss.global_position
	Direction = Boss.MovingDir.x
	Speed = InitialSpeed
	hide()
	Sprite.hide()

func enable() -> void:
	#Player._play_sound(AudioAttackBoomerang)
	show()
	ChangeTime.start()
	State = States.Initial
	Enabled = true
	global_position = Boss.global_position
	Direction = Boss.MovingDir.x
	Speed = InitialSpeed + Boss.Speed.x
	Sprite.show()

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Enabled):
		if(State == States.Initial):
			Speed += Acc*delta
			position.x += delta * Speed * State * Direction * clamp(ChangeTime.time_left/ChangeTime.wait_time, 0.1, 1.0)
		else:
			global_position.x = lerp(global_position.x, Boss.global_position.x, SpeedDelta*delta)
			global_position.y = lerp(global_position.y, Boss.global_position.y, SpeedDelta*delta)

func _on_timer_timeout() -> void:
	State *= -1
	Player._play_sound(AudioAttackBack)


func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") && Enabled):
		body.On_Death()
	elif(body.is_in_group("Boss") && State == States.Back):
		disable()
