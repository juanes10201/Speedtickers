extends AnimatableBody2D
@export var TimerExplode : Timer
@export var TimerRespawn : Timer
@export var OnWaterRay : RayCast2D
@export var NotOnWaterRay : RayCast2D
@export var AccEscapeWater : float = -5.0
@export var VelJumpWater : float = -300.0

@onready var Player = SaveGame.get_player()
var Velocity : Vector2 = Vector2(0.0, 0.0)

var SlamDisabledCollision : bool = false
@onready var WaterTileset = SaveGame.get_group_node("WaterTileset")

@onready var Sprite = $Sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_strech_tick(delta)
	if(!TimerExplode.is_stopped()):
		var StretchDif : float = 1-TimerExplode.time_left/TimerExplode.wait_time
		print(StretchDif)
		strech_size(1.0+.3*StretchDif, 1.0-.3*StretchDif, true)
	if(TimerRespawn.is_stopped()):
		#region Float On Water
		OnWaterRay.enabled = true
		if(OnWaterRay.is_colliding() && position.y >= WaterTileset.WaterLevel):
			print("OnWater")
			print(constant_linear_velocity)
			constant_linear_velocity.y = VelJumpWater
			Velocity.y += AccEscapeWater
			position.y += delta*Velocity.y
		else:
			constant_linear_velocity.y = 0.0
			#region Gravity
			if(!NotOnWaterRay.is_colliding() || NotOnWaterRay.global_position.y+NotOnWaterRay.target_position.y < WaterTileset.WaterLevel):
				Velocity.y -= AccEscapeWater
				position.y += delta*Velocity.y
			#endregion
			else:
				Velocity.y = 0.0
		#endregion
	else:
		OnWaterRay.enabled = false
		Velocity.y = 0.0


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		if(Player.GroundSmash || Player.Slide):
			Player.throw_enemies()
			TimerRespawn.start()
			print("Explode with Slam")
			_explode(true)
		else:
			Player._play_sound($AudioCharge)
			TimerExplode.start()
			$AnimationPlayer.play("interact")

func _explode(State : bool = true) -> void:
	print("Exploded")
	SlamDisabledCollision = false
	$AreaCollision.set_collision_mask_value(1, !State)
	set_collision_layer_value(9, !State)
	#$CollisionShape2D.disabled = State
	#$Area2D2/CollisionShape2D.disabled = State
	if(State):
		Player._stop_sound($AudioCharge)
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


func _on_area_disable_slam_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") && (Player.GroundSmash || Player.Slide)):
		set_collision_layer_value(9, false)
		SlamDisabledCollision = true


func _on_area_disable_slam_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player") && SlamDisabledCollision):
		set_collision_layer_value(9, true)
		SlamDisabledCollision = false



#region Streching and scaling
@onready var original_scale = Sprite.scale
var Stretch_speed : float = 20
func strech_size(X : float, Y : float, Override : bool = true, Speed : float = 20):
	Stretch_speed = Speed
	if(Override || (Sprite.scale.x == original_scale.x && Sprite.scale.y == original_scale.y) ):
		Sprite.scale = Vector2(original_scale.x*X, original_scale.y*Y)

func _strech_tick(delta : float):
	Sprite.scale.x += (original_scale.x - Sprite.scale.x) * Stretch_speed * delta
	Sprite.scale.y += ((original_scale.y) - Sprite.scale.y) * Stretch_speed * delta
#endregion
