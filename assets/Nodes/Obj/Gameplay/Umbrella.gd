extends Area2D

@export var PushVelocity : float = -320.0

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		body.Reset_Slide()
		body.Reset_Groundsmash(false, false, false)
		var BaseVelX : float = PushVelocity*sin(deg_to_rad(rotation_degrees))
		var BaseVely : float = PushVelocity*cos(deg_to_rad(rotation_degrees))
		print("Base Vel Y: " + str(BaseVely) )
		print("Base Vel X: " + str(BaseVelX) )
		body.velocity.y = BaseVely + -1*abs(body.velocity.y*.7)
		body.KickTimer.start()
		body.KickSpeed.x = BaseVelX * -100# + -1*abs(body.velocity.y*.7)
		body.PreJumpTime.stop()
		body.CoyoteTimer.stop()
		body._play_sound($Boing, true, true, 1.0, 1.0+(.2/700*abs(body.velocity.y)) )
		body.CanJump = false
		body.JumpedUmbrella = true
		body.Dashed = false
		body.set_collision_mask_value(4, false)
		body.set_collision_mask_value(3, false)
		body.DashTime.stop()
