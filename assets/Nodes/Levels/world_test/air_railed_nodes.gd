extends Node2D
@export var Positions : Array[Vector2]
@export var Progress : Array[float] = []

func _ready() -> void:
	for i in range(get_children().size()) :
		var Child = get_child(i)
		if(Child):
			Positions.append(Child.global_position)
			#print(Path.curve.get_closest_offset(to_local(Child.global_position)))

func get_position_child_index(Index : int) -> Vector2:
	return Positions[Index]

func get_position_child(Child : Node) -> Vector2:
	var Index : int = Child.get_index()
	return get_position_child_index(Index)
