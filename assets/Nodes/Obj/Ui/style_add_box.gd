extends Area2D

@export var StyleTypeAdd : int = 3
@export var StyleText : String = "Intended Skip"

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		LevelManager.AddStyle(StyleTypeAdd, StyleText)
