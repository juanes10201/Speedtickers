extends Button

@export var Scene : String = "select_level_bside"

func _on_pressed() -> void:
	var _scene_string : String = Scene
	get_tree().change_scene_to_file(_scene_string)
