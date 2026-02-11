extends Sprite2D
@onready var Player = SaveGame.get_player()
@export var DistanceMove : float = 300.0
@export var ReferencePlayer : Marker2D
@export var Boss : Node2D
@export var ExtraSprite : Sprite2D

func _ready() -> void:
	$AnimationPlayer.play("Idle")
	$AnimationPlayer2.play("Idle")

func _process(delta: float) -> void:
	offset.x = lerp(0.0, ReferencePlayer.position.x-Player.position.x, .10)
	offset.y = lerp(0.0, ReferencePlayer.position.y-Player.position.y, .05)
	if(ExtraSprite):
		ExtraSprite.offset = offset
	_strech_tick(delta)
	if(Boss.InFinalAttack): $AnimationPlayer2.play("FinalAttack")
	elif(Boss.Phase2): $AnimationPlayer2.play("Move")
	_strech_tick(delta)

#region Streching and scaling
@onready var original_scale = scale
var Stretch_speed : float = 20
func strech_size(X : float, Y : float, Override : bool = true, Speed : float = 20):
	Stretch_speed = Speed
	if(Override || (scale.x == original_scale.x && scale.y == original_scale.y) ):
		scale = Vector2(original_scale.x*X, original_scale.y*Y)

func _strech_tick(delta : float):
	scale.x += (original_scale.x - scale.x) * Stretch_speed * delta
	scale.y += ((original_scale.y) - scale.y) * Stretch_speed * delta
#endregion
