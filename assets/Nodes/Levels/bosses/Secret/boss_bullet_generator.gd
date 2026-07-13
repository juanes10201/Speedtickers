extends Node2D

func generate_bullet(amount : int, spawn_global_position : Vector2) -> void:
	var changed_amount : int = amount
	for Bullet in get_children():
		if(changed_amount <= 0): return
		if(!Bullet.Enabled):
			changed_amount -= 1
			Bullet.global_position = spawn_global_position
			Bullet.enable()
