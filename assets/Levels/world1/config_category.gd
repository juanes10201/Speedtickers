extends Node2D

@export var Category : Global.ConfigCategories = Global.ConfigCategories.audio

func _process(delta: float) -> void:
	if(get_parent() && Category == get_parent().Selected_Category):
		show()
	else:
		hide()
