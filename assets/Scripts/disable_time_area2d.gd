extends Area2D
@export var TimeState : bool = false

func _on_body_entered(body: Node2D) -> void:
	SaveGame.get_player()._set_time_state(TimeState, false)
