extends Node
class_name Global

enum KillBoxTypes{
	Red,
	Blue
}
enum BUTTON_ACTIONS{
	none,
	resume_game,
	restart_level,
	config_menu,
	move_to_scene,
	move_to_level_starting_with
}
enum OBJECT_ACTIONS{
	none,
	switch_killbox_type,
	MoveLava
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
