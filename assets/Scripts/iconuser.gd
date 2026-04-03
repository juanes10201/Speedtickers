#@tool
extends Sprite2D

func _ready():
	if OS.has_environment("USERNAME"):
		$BestUser.text = OS.get_environment("USERNAME")

func _process(delta):
	material.set_shader_parameter("mouse_position",get_global_mouse_position())
	material.set_shader_parameter("sprite_position",global_position)

func _update_best_scores(current_level : float) -> void:
	var time : float = SaveGame.getleveltime(current_level)
	$BestTime.text = str("%0.2f" % time) + " seg"
	if($BestTime.text == "0.00 seg"): $BestTime.text = "!!!!"
