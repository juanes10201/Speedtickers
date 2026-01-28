extends AnimatedSprite2D

func _process(delta: float) -> void:
	if(animation != get_parent().animation): play(get_parent().animation)
