extends Button

@export var Category : Global.ConfigCategories = Global.ConfigCategories.audio

@onready var PauseMenu : CanvasLayer = get_parent()
@export var SpriteButtonCategory : AnimatedSprite2D

@onready var InitialZIndex = z_index
@export var AnimPlayer : AnimationPlayer

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(PauseMenu.Selected_Category == Category):
		SpriteButtonCategory.animation = "Selected"
		z_index = InitialZIndex+1
	else:
		SpriteButtonCategory.animation = "Unselected"
		z_index = InitialZIndex

func _on_button_up() -> void:
	PauseMenu.Selected_Category = Category
	AnimPlayer.play("Click")
