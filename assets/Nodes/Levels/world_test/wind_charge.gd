extends Line2D

@export var MoveRef : Node2D
@export var Path : Path2D
@export var PathFollow : PathFollow2D
@export var MoveSpeed : float = 700
@export var MovOffset : Vector2 = Vector2(0.0, -5.0)
@export var EndWithSlam : bool = false
@export var RailedNodes : Node


func _ready() -> void:
	Path.global_position = self.global_position
	Path.curve.clear_points()
	for point in points:
		Path.curve.add_point(point)

func _process(delta: float) -> void:
	for RailedNode in RailedNodes.get_children():
		RailedNode.global_position = MoveRef.global_position + RailedNodes.get_position_child(RailedNode)
		if(RailedNode.Sprite):
			RailedNode.Sprite.rotation_degrees = PathFollow.rotation_degrees
