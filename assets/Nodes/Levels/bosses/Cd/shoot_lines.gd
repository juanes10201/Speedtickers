extends Node2D

func _ready() -> void:
	reset()

func reset() -> void:
	for line in get_children():
		line.points[1] = Vector2(0.0, 0.0)
		line.visible = false

func add_line(pos : Vector2):
	for line in get_children():
		if(!line.visible):
			print("oh shoot")
			line.points[1] = pos
			line.visible = true
			return

func shoot_all():
	print("kill")
	for line in get_children():
		var Raycast = line.get_child(0)
		if(Raycast):
			print("raycasted")
			Raycast.target_position = line.points[1]
			Raycast.enabled = true
			if(Raycast.is_colliding()):
				var hit_collider = Raycast.get_collider()
				hit_collider.On_Death()
	reset()
