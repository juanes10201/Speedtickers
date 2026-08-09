extends AnimatedSprite2D

@export var EditorCursor : Node2D


func _process(delta: float) -> void:
	animation = "tileset_" + str(EditorCursor.SelectedSubTile)
