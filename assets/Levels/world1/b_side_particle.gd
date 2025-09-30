extends Node2D
@onready var Player = $"../Player"
@onready var Inverted = $"Inverted"
@onready var Regular = $"Regular"

func _process(delta: float) -> void:
	if(Player.GlobalGravityDirection == Global.GravityDirections.INVERTED):
		Inverted.show()
		Inverted.emitting = true
		Regular.hide()
		Regular.emitting = false
	else:
		Regular.show()
		Regular.emitting = true
		Inverted.hide()
		Inverted.emitting = false
