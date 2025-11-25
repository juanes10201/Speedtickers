extends Node

@export var Audio_Bus_Name : String = "Music"

var Audio_Bus_Id : int


func _ready():
	Audio_Bus_Id = AudioServer.get_bus_index(Audio_Bus_Name)
	$ControlMusic.value = AudioServer.get_bus_volume_db(Audio_Bus_Id)
	$ProgressBar.value = $ControlMusic.value
	
func _on_control_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(Audio_Bus_Id, value)
	$ProgressBar.value = value
	$ProgressbarSelected.visible = true
	SaveGame.set_config_value("Audio_"+Audio_Bus_Name, value)


func _on_progress_bar_focus_entered() -> void:
	$ProgressbarSelected.visible = true


func _on_progress_bar_focus_exited() -> void:
	$ProgressbarSelected.visible = false


func _on_progress_bar_mouse_entered() -> void:
	$ProgressbarSelected.visible = true


func _on_progress_bar_mouse_exited() -> void:
	$ProgressbarSelected.visible = false
