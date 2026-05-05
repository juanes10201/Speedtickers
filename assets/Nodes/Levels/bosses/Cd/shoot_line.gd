extends Line2D


func _on_shoot_timer_timeout() -> void:
	get_parent().shoot_line(self)
