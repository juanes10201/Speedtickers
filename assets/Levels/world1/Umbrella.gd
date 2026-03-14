extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		print(body.velocity.y)
		body.Reset_Slide()
		body.Reset_Groundsmash(false, false, false)
		body.velocity.y = -320.0 + -1*abs(body.velocity.y*.7)
		body.PreJumpTime.stop()
		body.CoyoteTimer.stop()
		body._play_sound($Boing, true, true, 1.0, 1.0+(.2/700*abs(body.velocity.y)) )
		body.CanJump = false
