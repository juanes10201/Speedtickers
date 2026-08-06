extends Button

@export var Icon : AnimatedSprite2D
@export var EditorCursor : Node2D

var ButtonNode : int = 0
var ButtonSubNode : int = 0

func _on_pressed() -> void:
	print("Changed selected node to: " + str(ButtonNode))
	print("Changed selected sub-node to: " + str(ButtonSubNode))
	EditorCursor.SelectedNode = ButtonNode
	EditorCursor.SelectedSubNode = ButtonSubNode
	get_parent()._update_view()
