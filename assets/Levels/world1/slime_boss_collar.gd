extends RigidBody2D

var Destroy : bool = true

func _process(delta: float) -> void:
	#if(!Destroy): return
	for Ray in get_children():
		if(Ray is RayCast2D):
			Ray.enabled = true
			if(Ray.is_colliding()):
				var hit_collider = Ray.get_collider()
				if hit_collider.get_class() == "TileMapLayer":
					var hit_pos = Ray.get_collision_point()
					var cell = hit_collider.local_to_map(hit_collider.to_local(hit_pos))
					hit_collider.erase_cell(cell)
					hit_collider.erase_cell(cell-Vector2i(0, 1))


#func _on_destroy_tiles_timer_timeout() -> void:
#	Destroy = false
