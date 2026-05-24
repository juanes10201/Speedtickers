@tool
extends Line2D

@export var MoveRef : Node2D
@export var Path : Path2D
@export var PathFollow : PathFollow2D
@export var MoveSpeed : float = 700
@export var MovOffset : Vector2 = Vector2(0.0, -5.0)
@export var EndWithSlam : bool = false
@export var RailedNodes : Node

func _reload() -> void:
	Path.global_position = self.global_position
	Path.curve.clear_points()
	for point in points:
		Path.curve.add_point(point)

func _ready() -> void:
	_reload()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		for i in range(points.size()):
			var pos : Vector2 = Path.curve.get_point_position(i)
			if !pos or pos not in points:
				print("Reloading Wind Sand")
				_reload()
