extends AnimatedSprite2D

@export var EditorCursor : Node2D


func _process(delta: float) -> void:
	animation = "0_" + str(EditorCursor.SelectedSubTile)
