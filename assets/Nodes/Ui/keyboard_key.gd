extends Node2D

@export var TextLabel : RichTextLabel
@export var SpriteKeycap : AnimatedSprite2D

@onready var InputMapper : Node = get_parent().get_parent()

var Count : int = 0

func set_text(txt : String) -> void:
	TextLabel.text = txt
	SpriteKeycap.animation = "enabled"
	if(txt == ""):
		remove_text()

func remove_text() -> void:
	SpriteKeycap.animation = "disabled"
	TextLabel.text = ""

func _on_button_pressed() -> void:
	if(InputMapper):
		InputMapper.button_was_pressed(Count)
