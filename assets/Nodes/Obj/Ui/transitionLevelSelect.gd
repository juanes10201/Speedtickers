extends Sprite2D

@onready var Anim = $AnimationPlayer

func _ready() -> void:
	Anim.play("start")

func _process(delta: float) -> void:
	if(!Anim.is_playing()):
		Anim.play("idle")
