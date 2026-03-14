extends AnimatableBody2D
@export var TimerExplode : Timer
@export var TimerRespawn : Timer

@onready var Player = SaveGame.get_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#print($CollisionShape2D.disabled)


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		if(Player.GroundSmash):
			TimerRespawn.start()
			print("Explode with Slam")
			_explode(true)
		else:
			TimerExplode.start()
			$AnimationPlayer.play("interact")

func _explode(State : bool = true) -> void:
	print("Exploded")
	$Area2D2.set_collision_mask_value(1, !State)
	set_collision_layer_value(9, !State)
	#$CollisionShape2D.disabled = State
	#$Area2D2/CollisionShape2D.disabled = State
	if(State):
		hide()
		$AnimationPlayer.play("RESET")
		Player._play_sound($AudioPop)
	else:
		show()

func _on_timer_explode_timeout() -> void:
	_explode(true)
	TimerRespawn.start()


func _on_timer_respawn_timeout() -> void:
	_explode(false)
