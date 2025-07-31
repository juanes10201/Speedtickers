extends AnimatedSprite2D

@export var positions: Dictionary[String, Vector2] = {
	"Idle": Vector2(0, -0.58)
}

func offset_play(animation: String = ""):
	offset = positions[animation]
	play(animation)
