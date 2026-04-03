extends Node


func _on_control_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db()


func _on_control_sfx_value_changed(value: float) -> void:
	pass # Replace with function body.
