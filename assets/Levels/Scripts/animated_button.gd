extends AnimatedSprite2D

@export var ReadFromReplay : bool = false
@export var ButtonToPress : String = "player_jump"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(ReadFromReplay):
		if(SaveGame.get_player_replay().Replay.ReplayActions[ButtonToPress]):
			self.play("pressed")
		else:
			self.play("default")
	else:
		if(Input.is_action_pressed(ButtonToPress)):
			self.play("pressed")
		else:
			self.play("default")
