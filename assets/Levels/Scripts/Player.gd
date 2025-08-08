extends CharacterBody2D
class_name ClassPlayer

func enemy_jump():
	pass

#region Variable defining
enum Sides{
	LEFT,
	RIGHT,
	NONE,
	UP
}

var MoveLava : bool = false

var Sliding: Sides = Sides.NONE
var WasSliding : bool = false
var Slide : bool = false

var GroundSmash : bool = false
var PressingGroundSmash : bool = false

var WallJump : bool = false
var WallJumpSide: Sides = Sides.NONE
var WallJumpPreviousSide : Sides = Sides.NONE

var Speed : Vector2 = Vector2(10, 1)
var Acc : Vector2 = Vector2(500, 1)
var MaxAcc : Vector2 = Vector2(12000, 400)

var Dashed : bool = false
var DashAcc : Vector2 = Vector2(600, 400)
var DashMove : Vector2 = Vector2(0, 0) 

var HaveKey : bool = false

#region Export variables
@export var PlayIntro : bool = false
@export var juice : bool = true
@export var CountTime : bool = true
@export_group("Physics")
@export var Physics : bool = true

@export_subgroup("Jump")
@export_range(0, 7000.0, .5, "or_greater", "or_less") var WallJumpVelocity : float = 7000.0
@export_range(0, 100, .5, "or_greater", "or_less") var jump_height : float = 70.0
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_peak : float = 0.5
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_descent : float = 0.4

@export_subgroup("Groundsmash || Slide")
@export var SlideVelocity = 600
@export_range(0, 25000.0, .5, "or_greater", "or_less") var GroundSmashAcc : float = 25000.0
@export_range(0, 25.0, .5, "or_greater", "or_less") var JumpCancelAcc : float = 25.0

@export_subgroup("Death")
@export_range(0, 1.5, .25, "or_greater", "or_less") var TimeDeath : float = 1.5

@export_group("Level")
@export var PlayedBefore : bool = true
@export var EnemiesPhysics : bool = true

@export_group("Music")
@export var PlayMusic : bool = true
#endregion

var Paused : bool = false

@onready var ReturnToGameTime = $ReturnToGameTime


var LastDirection : float = 0
var direction := Input.get_axis("ui_left", "ui_right")

@onready var DashTime : Timer = $DashTime
@onready var PreJumpTime : Timer = $PreJumpTime
@onready var CoyoteTimer : Timer = $CoyoteTimer
@onready var Sprite : AnimatedSprite2D = $Sprite2D
@onready var EnemyGroundSlamTimer : Timer = $EnemyGroundSlamTimer
@onready var PreWallJumpTimer : Timer = $PreWallJumpTimer
@onready var Camera : Camera2D = $Camera2D
@onready var ParticlesLanding : AnimatedSprite2D = $ParticlesLanding
@onready var ParticlesSlide : GPUParticles2D = $ParticlesSlide
@onready var ParticlesJump : GPUParticles2D = $ParticlesJump
@onready var ParticlesDeathFloor : GPUParticles2D = $ParticlesDeathFloor
@onready var ParticlesDeathAir : GPUParticles2D = $ParticlesDeathAir
@onready var SlidingOnRamp : bool = false

@onready var AudioDash : AudioStreamPlayer = $AudioDash
@onready var AudioWalk : AudioStreamPlayer = $AudioWalk
@onready var AudioSlide : AudioStreamPlayer = $AudioSlide
@onready var AudioGroundsmash : AudioStreamPlayer = $AudioGroundsmash
@onready var AudioWind : AudioStreamPlayer = $AudioWind
@onready var AudioJump : AudioStreamPlayer = $AudioJump
@onready var AudioWalkSand : AudioStreamPlayer = $AudioWalkSand
@onready var AudioSwitch : AudioStreamPlayer = $AudioSwitch
@onready var AudioKey : AudioStreamPlayer = $AudioKey
@onready var AudioDeath : AudioStreamPlayer = SongPlayer.AudioDeath
@onready var AudioOrbGravity : AudioStreamPlayer = $AudioOrbGravity

@onready var AudioSlimeKill : AudioStreamPlayer = $AudioSlimeGroundsmash #AudioSlimeKill
@onready var AudioSlimeMove : AudioStreamPlayer = $AudioSlimeMove
@onready var AudioSlimeGroundsmash : AudioStreamPlayer = $AudioSlimeGroundsmash

@onready var TransitionOut : Node2D = $"../CanvasLayer/TransitionOut"
@onready var TransitionIn : Node2D = $"../CanvasLayer/TransitionIn"

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var UI : CanvasLayer = $"../CanvasLayer/"

@onready var DashParticles1 = $"DashParticles1"

var Pause_fadeout : bool = false
var OnSand : bool = false
var was_on_floor : bool = true
var Dead : bool = false

var EnabledKillBox : Global.KillBoxTypes = Global.KillBoxTypes.Red

@onready var OriginalPos : Vector2 = self.position

var GravityDirection : Global.GravityDirections = Global.GravityDirections.MAIN

var SwitchedGravity : bool = false
var PlayedSwitchedGravityAnimation : bool = false

enum AirSides{
	Jumping = 1,
	Falling = 2,
	NONE = 0
}

var AirState : AirSides = AirSides.NONE

#endregion

func _play_dash_particles():
	DashParticles1.emitting = true
func _stop_dash_particles():
	DashParticles1.emitting = false

#region Debug
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F9:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_F10:
			var _scene_string = "res://assets/Levels/world1/main_menu_w_level_preview.tscn"
			get_tree().change_scene_to_file(_scene_string)
		elif event.keycode == KEY_F11:
			var _scene_string = "res://assets/Levels/world1/select_level.tscn"
			get_tree().change_scene_to_file(_scene_string)
		elif event.keycode == KEY_F12:
			LevelManager.ReturnAfterTimerInExpo = !LevelManager.ReturnAfterTimerInExpo
#endregion

func _ready() -> void:
	if(Physics && Edition.Mobile):
		var MobileControls = preload("res://assets/Levels/ui_android_control.tscn")
		if (MobileControls != null):
			var MobileControlsInstance = MobileControls.instantiate()
			if(MobileControlsInstance != null): UI.add_child(MobileControlsInstance)
	
	if(PlayIntro):
		#If level is not identified search for it
		Global.Level = LevelManager.LevelOrder.find(get_tree().current_scene)
	
	if(TransitionOut): TransitionOut.hide()
	if(TransitionIn): TransitionIn.show()
	if(TransitionIn): TransitionIn.fade_out()

	print(LevelManager.get_level())
	if(PlayIntro):
		PlayedBefore = false
		#PlayedBefore = SaveGame.IfPlayedFirstTime()
	if(!PlayedBefore && !Edition.DoneIntro):
		Camera.offset.y = -226.31
		FrameFreeze(.4, 2)
	
	#region Change music style to ingame
	if(PlayMusic):
		SongPlayer.MusicState = SongPlayer.MusicStates.ingame
	#endregion
	
#region Physics proccess
func _physics_process(delta: float) -> void:
	if(_is_on_floor()):
		SwitchedGravity = false
		PlayedSwitchedGravityAnimation = false
	#region Set direction
	#Sprite direction
	Sprite.flip_h = false if LastDirection >= 0 else true
	$Wallchecker.rotation_degrees = 90 if LastDirection < 0 else -90
	_pause_menu_end_tick()
	#endregion
	if(Physics):
		if(velocity.y > 0):
			AirState = AirSides.Falling
		elif(velocity.y < 0):
			AirState = AirSides.Jumping
		else:
			AirState = AirSides.NONE
		if(PlayIntro):
			Camera.offset.y = lerpf(Camera.offset.y, 23.85, 1*delta)
		
		WasSliding = false
		var direction := Input.get_axis("ui_left", "ui_right")
		
		if(SlidingOnRamp && !_is_on_floor()): velocity.y = SlideVelocity * GravityDirection
		
		if(Input.is_action_just_pressed("menu_pause")): _pause_game()
		
		if(!DashTime.is_stopped()):
			_play_dash_particles()
		else:
			_stop_dash_particles()
		
		if(SwitchedGravity && !PlayedSwitchedGravityAnimation ):
			if(!Sprite.is_playing() && Sprite.animation == "Switch_gravity"):
				PlayedSwitchedGravityAnimation = true
			Sprite.offset_play("Switch_gravity")
		elif(!DashTime.is_stopped()):
			Sprite.offset_play("Dash")
		elif(WallJump):
			Sprite.offset_play("Wall_jump")
		elif(GroundSmash):
			Sprite.offset_play("Groundsmash")
		elif(AirState == AirSides.Falling):
			if(!Sprite.animation == "Jump"):
				Sprite.offset_play("Jump")
		elif(AirState == AirSides.Jumping):
			if(!Sprite.animation == "Jump_start"):
				Sprite.offset_play("Jump_start")
		elif(!Slide):
			if(direction):
				Sprite.offset.y = -1.605
				Sprite.offset_play("Walking")
			else:
				Sprite.offset_play("Idle")
		if(Sprite.offset.y != -0.58 && Sprite.animation != "Walking"):
			Sprite.offset.y = -0.58
		
		#region Particles
		#region Jump initial particles
		if(!_is_on_floor() && was_on_floor && !ParticlesLanding.is_playing()):
			ParticlesLanding.position = self.position
			ParticlesLanding.position.y -= 5
			ParticlesLanding.set_as_top_level(true)
			ParticlesLanding.play("default")
			ParticlesLanding.show()
		if(!ParticlesLanding.is_playing()):
			ParticlesLanding.hide()
		#endregion  
		
		if(_is_on_floor() && !was_on_floor):
			strech_size(1.7, 0.5)
			ParticlesJump.emitting = false
			ParticlesLanding.hide()
		if(!_is_on_floor()):
			ParticlesJump.emitting = true
		#endregion
		_strech_tick(delta)
		_physics_apply_gravity(delta)
		_physics_jump(delta)
		_physics_h_movement(delta)
		_physics_dash(delta)
		_physics_slide_and_groundsmash(delta)
		_physics_walljump(delta)

		#region Apply horizontal movement
		# Update velocity based on Speed and Dash status
		if(DashTime.is_stopped()): velocity.x = Speed.x*delta
		else: velocity.x = DashMove.x
		#endregion
		
		#region Prevent overflow
		if(Acc.x * GravityDirection > MaxAcc.x): Acc.x = MaxAcc.x * GravityDirection
		if(velocity.y * GravityDirection > MaxAcc.y && !GroundSmash): velocity.y = MaxAcc.y * GravityDirection
		#endregion
		
		#region Apply movement	
		if(direction != 0): LastDirection = direction
		
		was_on_floor = _is_on_floor()
		
		#region Sand Sound
		if(OnSand && !Slide): _play_sound(AudioWalkSand, false)
		else: _stop_sound(AudioWalkSand)
		#endregion
	
		# Move the character
		move_and_slide()
		#endregion
	
	
	
	#region Destructible walls w slide
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if the collider is a destructible wall
		if (collider.is_in_group("destructible_walls_slide")):
			# Check the wall's Sliding variable
			if Slide:
				collider.destroy()  # Call the wall's destroy method
	#endregion
#endregion

#region Walking sound
func _play_sound(body, override):
	if(body):
		if(override && body.playing):
			body.stop()
		if(!body.playing):
			if(body == AudioSlide): body.volume_db = -10
			body.pitch_scale = randf_range(0.8, 1)
			body.play()
func _stop_sound(body):
	if(body.playing):
		body.stop()
func _fade_sound(body):
	var tween_fade_sound = get_tree().create_tween()
	tween_fade_sound.tween_property(body, "volume_db", -80, 0.5)
	tween_fade_sound.tween_callback(body.stop)
#endregion

#region Pause and menu
func _pause_menu_end_tick() -> void:
	if(Pause_fadeout && ReturnToGameTime.is_stopped()):
		var pause = get_node("../CanvasLayer/pause_menu")
		if(pause):
			pause.queue_free()
			
		#Get timer and pause
		$"../Time_Left".paused = false	
		#Stop player movement
		Physics = true
		#Stop enemie movement
		EnemiesPhysics = true
		Pause_fadeout = false
		Paused = false
		SongPlayer.MusicState = SongPlayer.MusicStates.ingame

var pause_menu_instance = null

func _pause_game() -> void:
	if(!Paused):
		_spawn_pause_menu()
		#Get timer and pause
		$"../Time_Left".paused = true	
		#Stop player movement
		Physics = false
		#Stop enemie movement
		EnemiesPhysics = false
		Paused = !Paused
	else:
		_unpause_game()

func _unpause_game() -> void:
	pause_menu_instance.Transition.Anim.play("fade_movement")
	ReturnToGameTime.start()
	Pause_fadeout = true
	
	
func _spawn_pause_menu() -> void:
	var pause_menu = preload("res://assets/Levels/world1/pause_menu.tscn")
	if (pause_menu):
		pause_menu_instance = pause_menu.instantiate()
		UI.add_child(pause_menu_instance)
#endregion

#region Gravity
func _physics_apply_gravity(delta: float) -> void:
	if (!_is_on_floor()):
		if(was_on_floor): CoyoteTimer.start()
		if(!WallJump && DashTime.is_stopped()):
			velocity.y += get_gravity_player() * Acc.y * delta * GravityDirection
			if(!WallJump):
				if(velocity.y*GravityDirection < 0): 
					strech_size(0.8, 1.2, true)
				elif(velocity.y*GravityDirection >= MaxAcc.y):
					strech_size(0.8, 1.2, true)
					#_play_sound(AudioWind, false)
		#else: velocity.y += Speed.y * delta
	if (_is_on_floor()):
		Dashed = false
		_stop_sound(AudioWind)
		if(GroundSmash):
			ParticlesLanding.position = self.position
			ParticlesLanding.position.y -= 10
			ParticlesLanding.set_as_top_level(true)
			ParticlesLanding.play("groundsmash")
			ParticlesLanding.show()
			AudioGroundsmash.play()
			GroundSmash = false
			Camera.Shake(10.0, 10.0)
			enemy_jump()
			EnemyGroundSlamTimer.start()
		if(Sliding == Sides.UP):
			Sliding = Sides.NONE
			Slide = false
#endregion

#region Invert Gravity
func _invert_gravity() -> void:
	#DoJump()
	SwitchedGravity = true
	velocity.y = 100 * GravityDirection
	GravityDirection *= -1
	Dashed = false
	strech_size(1.5, 1.2)
	$ParticlesOrb.emitting = true
	_play_sound(AudioOrbGravity, true)
	
#endregion

#region jump
func _physics_jump(delta: float) -> void:
	# Handle jump.
	if ((!PreJumpTime.is_stopped() && (_is_on_floor() || WallJump || !CoyoteTimer.is_stopped()) ) || (!PreWallJumpTimer.is_stopped() && Input.is_action_pressed("player_jump")) ):
		DoJump()
	#Cancel jump
	if(velocity.y < 0 && !Input.is_action_pressed("player_jump")):
		velocity.y += JumpCancelAcc * GravityDirection
	
	if(Input.is_action_pressed("player_jump")): PreJumpTime.start()
	
	#Pre-detect jump
#endregion

func DoJump() -> void:
	if(Sliding != Sides.NONE):
		Sliding = Sides.UP
		Speed.x = Acc.x*2 if LastDirection >= 0 else Acc.x*-2
	velocity.y = jump_velocity * GravityDirection
	#strech_size(1.1, 0.7, true, 70)
	Controller_Vibrate_Player_Movement(0.2)
	_play_sound(AudioJump, false)
	#region WallJump case
	if(WallJump || !PreWallJumpTimer.is_stopped()):
		Speed.x = WallJumpVelocity*-1 if WallJumpPreviousSide == Sides.RIGHT else WallJumpVelocity
		PreWallJumpTimer.stop()
		velocity.y -= 50 * GravityDirection
	#endregion

#region Horizontal movement
func _physics_h_movement(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	# Fix the Movement Speed accumulating in the side touching a wall
	if(WallJump && WallJumpSide == Sides.RIGHT && Speed.x > 0): Speed.x = 0
	if(WallJump && WallJumpSide == Sides.LEFT && Speed.x < 0): Speed.x = 0
	
	# Get the input direction and handle the movement/deceleration.
	if (!WallJump && direction && Speed.x < MaxAcc.x && Speed.x > MaxAcc.x*-1):
		#_play_sound(AudioWalk, false)
		if((direction > 0 && Speed.x < 0) || (direction < 0 && Speed.x > 0)): Speed.x += Acc.x * direction
		#Move faster if coming from Walljump
		if((WallJumpPreviousSide == Sides.LEFT && direction < 0) || (WallJumpPreviousSide == Sides.RIGHT && direction > 0) && !PreWallJumpTimer.is_stopped()): Speed.x += Acc.x * direction *2
		
		Speed.x += Acc.x * direction  # Adjust speed based on input direction
	else:
		if(Speed.x > 0): Speed.x -= Acc.x
		if(Speed.x < 0): Speed.x += Acc.x
		#_stop_sound(AudioWalk)
#endregion

#region Slide and Ground Smash
func _physics_slide_and_groundsmash(delta: float) -> void:
	if((Input.is_action_pressed("player_slide") || PressingGroundSmash)):
		#Groundsmash
		if(!_is_on_floor() && !Slide && (Sliding != Sides.UP) ):# || velocity.y < jump_height+10)):
			velocity.y = SlideVelocity * GravityDirection
			GroundSmash = true
			PressingGroundSmash = true
			set_collision_mask_value(4, false)
		#Slide
		elif(Sliding != Sides.UP && !PressingGroundSmash):
			_play_sound(AudioSlide, false)
			Controller_Vibrate_Player_Movement(0.2)
			Speed.x = GroundSmashAcc if Sliding == Sides.RIGHT else GroundSmashAcc * -1
			#if(SlidingOnRamp): Speed.x *= 1.2
			if(Sliding == Sides.NONE): Sliding = Sides.RIGHT if LastDirection > 0  else Sides.LEFT
			Slide = true
			ParticlesSlide.emitting = true
			#strech_size(1, .6)
			Sprite.play("Slide")
			set_collision_mask_value(3, false)
	elif(Sliding != Sides.NONE):
		#strech_size(1, 1)
		#Speed.x -= Acc.x * LastDirection
		#if((Speed.x <= 250 && Speed.x > 0) || (Speed.x >= -250 && Speed.x < 0)):
		_fade_sound(AudioSlide)
		Sliding = Sides.NONE
		ParticlesSlide.emitting = false
		Slide = false
		if(Sliding != Sides.UP): Speed.x = 0
	#if(Sliding == Sides.UP):
		#strech_size(1, 1)
	if(!Slide): set_collision_mask_value(3, true)
	if(!GroundSmash): set_collision_mask_value(4, true)
	if(!Input.is_action_pressed("player_slide") && _is_on_floor() ):
		PressingGroundSmash = false
	
	#endregion

#region Dash
func _physics_dash(delta: float) -> void:
	#Dash
	if(Input.is_action_just_pressed("player_dash") && !Dashed):
		Dashed = true
		AudioDash.pitch_scale = randf_range(0.8, 1.2)
		AudioDash.play()
		strech_size(2, 0.5)
		DashTime.start()
		DashMove = DashAcc * LastDirection
		#Cancel groundsmash:
		GroundSmash = false
		PressingGroundSmash = false
		Controller_Vibrate_Player_Movement(0.7)
	#Dash movement
	if(DashTime.is_stopped()):
		if(DashMove.x > 250): DashMove.x -= Acc.x * LastDirection 
		else: DashMove.x = 0
		if(DashMove.y > 250): DashMove.y -= Acc.y * LastDirection
		else: DashMove.y = 0
	#When dashing suspend in air
	else: velocity.y = 0 * GravityDirection
#endregion

#region WallJump
func _physics_walljump(delta: float) -> void:
	#The idea is to mantain some vertical movement, but still be able to jump more than before, like SuperMeatBoy
	var direction := Input.get_axis("ui_left", "ui_right")
	if(is_near_wall() && direction && !Slide):
		Dashed = false
		velocity.y += 50* delta * GravityDirection
		if(!WallJump): velocity.y = 50 * GravityDirection
		WallJump = true
		if(direction > 0):
			WallJumpSide = Sides.RIGHT
			if(WallJumpPreviousSide == Sides.NONE): WallJumpPreviousSide = Sides.RIGHT
		else:
			WallJumpSide = Sides.LEFT
			if(WallJumpPreviousSide == Sides.NONE):  WallJumpPreviousSide = Sides.LEFT
	else:
		if(WallJump):
			PreWallJumpTimer.start()
		if(PreWallJumpTimer.is_stopped()): WallJumpPreviousSide = Sides.NONE
		WallJump = false
	#endregion

#region Controller vibration
func Controller_Vibrate_Player_Movement(Force):
	Input.start_joy_vibration(0, 0.3 * Force, 0.4 * Force, 0.2)
#endregion


#region Juice

#region Streching and scaling
@onready var original_scale = Sprite.scale
var Stretch_speed : float = 20
func strech_size(X : float, Y : float, Override : bool = true, Speed : float = 20):
	Stretch_speed = Speed
	if(juice):
		if(Override || (Sprite.scale.x == original_scale.x && Sprite.scale.y == original_scale.y) ):
			Sprite.scale = Vector2(original_scale.x*X, original_scale.y*Y*GravityDirection)

func _strech_tick(delta : float):
	if(juice):
		Sprite.scale.x += (original_scale.x - Sprite.scale.x) * Stretch_speed * delta
		Sprite.scale.y += ((original_scale.y*GravityDirection) - Sprite.scale.y) * Stretch_speed * delta
#endregion

#region FrameFreeze
var FrameFreezeEnabled : bool = false
func FrameFreeze(TimeScale, duration):
	if(!FrameFreezeEnabled):
		FrameFreezeEnabled = true
		Engine.time_scale = TimeScale
		await(get_tree().create_timer(duration * TimeScale).timeout)
		Engine.time_scale = 1
		FrameFreezeEnabled = false
#endregion
#endregion

func get_gravity_player() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

#region Death
func On_Death():
	if(_is_on_floor()): ParticlesDeathFloor.emitting = true
	else: ParticlesDeathAir.emitting = true
	Sprite.hide()
	Physics = false
	Dead = true
	_play_sound(AudioDeath, false)
	
	#TransitionOut.show()
	#TransitionOut.fade_out()
	if(!Edition.Is_in_editor):
		await(get_tree().create_timer(TimeDeath).timeout)
		if get_tree():
			get_tree().reload_current_scene()
#endregion

func _is_on_floor() -> bool:
	if(GravityDirection == 1):
		return is_on_floor()
	else:
		return is_on_ceiling()

#region Wall Checker
func is_near_wall() -> bool:
	return $Wallchecker.is_colliding()
#endregion
