extends Area2D

@export var StopAction = "player_dash"
var Done : bool = true
var HadStopped : bool = false
@onready var TutorialCanvas : CanvasModulate = $"../CanvasModulate"
@onready var Player = SaveGame.get_player()
@export var WaitAnimation = "Jump"
@export var PlayerHasToBeInGround : bool = false

var WillDo : bool = false

var ShowTutorial : bool = false

func _ready() -> void:
	if($Hologram): $Hologram.play("disabled")
	if($Tutorial): $Tutorial.modulate.a = 0.0
	if(TutorialCanvas): TutorialCanvas.hide()

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		_stop()

func _stop() -> void:
	if($Hologram): $Hologram.play("show")
	if(PlayerHasToBeInGround && !Player._is_on_floor()):
		WillDo = true
		return
	if(HadStopped): return
	if($Tutorial): ShowTutorial = true
	Done = false
	Player.Physics = false
	TutorialCanvas.show()
	Player.LastDirection = 1
	Player.direction = 1
	Player.Sprite.play(WaitAnimation)

func _resume_mov() -> void:
	if($Tutorial): ShowTutorial = false
	Done = true
	TutorialCanvas.show()
	Player.Physics = true
	HadStopped = true
	TutorialCanvas.hide()

var GreyVal : float = 1.0

func _process(delta: float) -> void:
	if(WillDo && Player._is_on_floor()):
		_stop()
	if($Tutorial):
		if(!ShowTutorial): $Tutorial.modulate.a = 0.0
		else:
			if($Tutorial/Text): $Tutorial/Text.animate()
			$Tutorial.modulate.a = lerp($Tutorial.modulate.a, 1.0, 1*delta)
	if(!Done):
		GreyVal = lerp(GreyVal, .1, 5*delta)
		TutorialCanvas.modulate.a = GreyVal
		if(Input.is_action_pressed(StopAction)):
			_resume_mov()


func _on_stop_remover_body_entered(body: Node2D) -> void:
	if($Hologram): $Hologram.play("hide")
	if($Tutorial/Text): $Tutorial/Text.Animate = false
	await get_tree().create_timer(1.0).timeout
	queue_free()
