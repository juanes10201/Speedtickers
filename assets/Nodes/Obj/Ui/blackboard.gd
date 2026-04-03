extends AnimatedSprite2D
@export var anim_to_play = "default"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play(anim_to_play)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
