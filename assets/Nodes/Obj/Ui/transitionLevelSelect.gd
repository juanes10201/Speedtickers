extends Sprite2D

@onready var Anim = $AnimationPlayer

func _ready() -> void:
	$AnimationPlayer.play("start")

func _process(delta: float) -> void:
	if(!$AnimationPlayer.is_playing()):
		$AnimationPlayer.play("idle")
