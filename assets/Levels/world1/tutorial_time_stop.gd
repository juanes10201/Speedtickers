extends Area2D

@export var StopAction = "player_dash"
var Done : bool = true
var HadStopped : bool = false
@onready var TutorialCanvas : CanvasModulate = $"../CanvasModulate"
@onready var Player = SaveGame.get_player()
@export var WaitAnimation = "Jump"

func _ready() -> void:
	if(TutorialCanvas): TutorialCanvas.hide()

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		_stop()

func _stop() -> void:
	if(HadStopped): return
	Done = false
	Player.Physics = false
	TutorialCanvas.show()
	Player.LastDirection = 1
	Player.direction = 1
	Player.Sprite.play(WaitAnimation)

func _resume_mov() -> void:
	Done = true
	TutorialCanvas.show()
	Player.Physics = true
	HadStopped = true
	TutorialCanvas.hide()

var GreyVal : float = 1.0

func _process(delta: float) -> void:
	if(!Done):
		GreyVal = lerp(GreyVal, .1, 5*delta)
		TutorialCanvas.modulate.a = GreyVal
		if(Input.is_action_pressed(StopAction)):
			_resume_mov()


func _on_stop_remover_body_entered(body: Node2D) -> void:
	queue_free()
