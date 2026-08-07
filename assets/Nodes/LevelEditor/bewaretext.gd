extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(OS.has_feature("retail")):
		show()
	else:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_button_down() -> void:
	queue_free()
