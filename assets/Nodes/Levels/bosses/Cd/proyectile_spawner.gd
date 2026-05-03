extends Node2D


func spawn_proyectiles() -> void:
	for Proyectile in get_children():
		await get_tree().create_timer(0.2).timeout
		Proyectile.restart()
