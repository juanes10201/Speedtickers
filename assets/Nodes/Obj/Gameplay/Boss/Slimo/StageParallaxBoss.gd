extends Sprite2D
@onready var Player = SaveGame.get_player()
@export var DistanceMove : float = 300.0
@export var ReferencePlayer : Marker2D
@export var Boss : Node2D
@export var ExtraSprite : Sprite2D
@export var Stage : AnimatedSprite2D
var PreviousX : float = 0.0

func _ready() -> void:
	$AnimationPlayer.play("Idle")
	$AnimationPlayer2.play("Idle")

func _process(delta: float) -> void:
	$Sprite2D.offset = offset
	$Sprite2D2.offset = offset
	offset.x = lerp(0.0, ReferencePlayer.position.x-Player.position.x, .10)
	offset.y = lerp(0.0, ReferencePlayer.position.y-Player.position.y, .05)
	if(ExtraSprite):
		ExtraSprite.offset = offset
	_strech_tick(delta)
	if(Boss.InFinalAttack): $AnimationPlayer2.play("FinalAttack")
	elif(Boss.Phase2): $AnimationPlayer2.play("Move")
	#Stage.speed_scale = clamp(abs(PreviousX-position.x/delta)/20000.0, 0.5, 1.0)
	if(abs(PreviousX-position.x/delta) > 10000.0):
		if(position.x > PreviousX):
			_play_stage_anim("move_right")
		elif(position.x < PreviousX):
			_play_stage_anim("move_left")
	elif(abs(PreviousX-position.x/delta) == 0.0):
		_play_stage_anim("idle")
	PreviousX = position.x

func _play_stage_anim(anim : String):
	if(Stage.animation == "explode"): return
	if(Stage.animation != anim):
		Stage.play(anim)

#region Streching and scaling
@onready var original_scale = scale
var Stretch_speed : float = 5
func strech_size(X : float, Y : float, Override : bool = true, Speed : float = 20):
	Stretch_speed = Speed
	if(Override || (scale.x == original_scale.x && scale.y == original_scale.y) ):
		scale = Vector2(original_scale.x*X, original_scale.y*Y)

func _strech_tick(delta : float):
	scale.x += (original_scale.x - scale.x) * Stretch_speed * delta
	scale.y += ((original_scale.y) - scale.y) * Stretch_speed * delta
	if(ExtraSprite): ExtraSprite.scale = scale
#endregion
