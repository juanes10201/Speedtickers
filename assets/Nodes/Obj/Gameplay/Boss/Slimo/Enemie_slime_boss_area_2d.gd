extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#get_parent().disable_collision()
	pass

func _on_area_entered(area: Area2D) -> void:
	if(!get_parent().InteractPlayer): return
	var playerbody = area.get_parent()
	if(get_parent().Enabled):
		if(playerbody.is_in_group("Player")):
			if(area.is_in_group("PlayerEnemiesCollision")):
				#Disable enemie collision if enemy type == 0
				if(get_parent().check_collision()): get_parent().disable_collision()
				#If sliding and enemy type's == 0 then do slide action 
				#if(playerbody.Slide):
				#	get_parent()._on_player_slide_signal()
			elif(area.is_in_group("PlayerHitBox")):# && !playerbody.Slide):
				if(playerbody.Dashed && !playerbody.DashTime.is_stopped()):
					get_parent()._on_damage_boss_body_entered(playerbody)
				else:
					playerbody.On_Death()
		else:
			if(!get_parent().check_collision()): get_parent().enable_collision()
