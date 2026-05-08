extends Node2D

var global_pos : Array[Vector2] = []

func _process(delta: float) -> void:
	if(global_pos):
		for i in range(global_pos.size()):
			var line = get_child(i)
			if(line && line is Line2D):
				var local_pos = (global_pos[i]-global_position).normalized()*2000
				line.points[1] = local_pos
				var Raycast = line.get_child(0)
				if(Raycast):
					Raycast.target_position = line.points[1]

func _ready() -> void:
	reset()

func reset() -> void:
	global_pos.clear()
	for line in get_children():
		line.points[1] = Vector2(0.0, 0.0)
		line.visible = false

func add_line(pos : Vector2):
	global_pos.append(pos)
	var local_pos = pos-global_position
	for line in get_children():
		if(!line.visible):
			#print("oh shoot")
			line.points[1] = local_pos.normalized()*2000
			line.visible = true
			return

func shoot_line(line : Node2D) -> void:
	for Raycast in line.get_children():
		#print(Raycast)
		if(Raycast && Raycast is RayCast2D):
			Raycast.target_position = line.points[1]
			Raycast.enabled = true
			if(Raycast.is_colliding()):
				var hit_collider = Raycast.get_collider()
				hit_collider.On_Death()
				

func shoot_all():
	#print("kill")
	for line in get_children():
		shoot_line(line)
	reset()
