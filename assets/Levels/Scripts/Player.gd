extends CharacterBody2D

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

var Speed = Vector2(10, 1)
var Acc = Vector2(500, 1)
var MaxAcc = Vector2(12000, 400)

var Dashed : bool = false
var DashAcc = Vector2(600, 400)
var DashMove = Vector2(0, 0) 

var HaveKey : bool = false

#@export var JUMP_VELOCITY = -350.0
@export var WallJumpVelocity : float = 7000.0

@export var JumpCancelAcc : float = 25.0
@export var GroundSmashAcc : float = 25000.0

@export var TimeDeath : float = 1.5
var Physics : bool = true
var EnemiesPhysics : bool = true
var Paused : bool = false
@onready var ReturnToGameTime = $ReturnToGameTime

var LastDirection : float = 0
var direction := Input.get_axis("ui_left", "ui_right")

@export var SlideVelocity = 600

@onready var DashTime = $DashTime
@onready var PreJumpTime = $PreJumpTime
@onready var CoyoteTimer = $CoyoteTimer
@onready var Sprite = $Sprite2D
@onready var EnemyGroundSlamTimer = $EnemyGroundSlamTimer
@onready var PreWallJumpTimer = $PreWallJumpTimer
@onready var Camera = $Camera2D
@onready var ParticlesLanding = $ParticlesLanding
@onready var ParticlesSlide = $ParticlesSlide
@onready var ParticlesJump = $ParticlesJump
@onready var ParticlesDeathFloor = $ParticlesDeathFloor
@onready var ParticlesDeathAir = $ParticlesDeathAir
@onready var SlidingOnRamp : bool = false

@onready var AudioDash = $AudioDash
@onready var AudioWalk = $AudioWalk
@onready var AudioSlide = $AudioSlide
@onready var AudioGroundsmash = $AudioGroundsmash
@onready var AudioWind = $AudioWind
@onready var AudioJump = $AudioJump
@onready var AudioWalkSand = $AudioWalkSand
@onready var AudioSwitch = $AudioSwitch
@onready var AudioKey = $AudioKey

@onready var AudioSlimeKill = $AudioSlimeGroundsmash #AudioSlimeKill
@onready var AudioSlimeMove = $AudioSlimeMove
@onready var AudioSlimeGroundsmash = $AudioSlimeGroundsmash

@onready var TransitionOut = $"../CanvasLayer/TransitionOut"
@onready var TransitionIn = $"../CanvasLayer/TransitionIn"

@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var Pause_fadeout : bool = false

var OnSand : bool = false

var was_on_floor : bool = true

var Dead : bool = false


var EnabledKillBox = Global.KillBoxTypes.Red

@export var PlayedBefore : bool = true

#endregion

#region Debug
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F9:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_F10:
			var _scene_string= "res://assets/Levels/world1/main_menu_expo.tscn"
			get_tree().change_scene_to_file(_scene_string)
#endregion

func _ready() -> void:
	if(TransitionOut): TransitionOut.hide()
	if(TransitionIn): TransitionIn.show()
	if(TransitionIn): TransitionIn.fade_out()
	
	if($"../Flag".current_level == 1): 
		PlayedBefore = false
		#PlayedBefore = SaveGame.IfPlayedFirstTime()
	if(!PlayedBefore):
		Camera.offset.y = -226.31
		FrameFreeze(.4, 2)
	
	#region Change music style to ingame
	SongPlayer.MusicState = SongPlayer.MusicStates.ingame
	#endregion
	
#region Physics proccess
func _physics_process(delta: float) -> void:
	if($"../Flag".current_level == 1):
		Camera.offset.y = lerpf(Camera.offset.y, 23.85, 1*delta)
	
	WasSliding = false
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if(SlidingOnRamp && !is_on_floor()): velocity.y = SlideVelocity
	
	if(Input.is_action_just_pressed("menu_pause")): _pause_game()
	
	if(!Slide):
		if(direction):
			Sprite.play("Walking")
		else: Sprite.play("Idle")
	
	#region Particles
	#region Jump initial particles
	if(!is_on_floor() && was_on_floor && !ParticlesLanding.is_playing()):
		ParticlesLanding.position = self.position
		ParticlesLanding.position.y -= 5
		ParticlesLanding.set_as_top_level(true)
		ParticlesLanding.play("default")
		ParticlesLanding.show()
	if(!ParticlesLanding.is_playing()):
		ParticlesLanding.hide()
	#endregion  
	
	if(is_on_floor() && !was_on_floor):
		strech_size(1.7, 0.5)
		ParticlesJump.emitting = false
		ParticlesLanding.hide()
	if(!is_on_floor()):
		ParticlesJump.emitting = true
	#endregion
	
	_pause_menu_end_tick()
	
	if(Physics):
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
		if(Acc.x > MaxAcc.x): Acc.x = MaxAcc.x
		if(velocity.y > MaxAcc.y && !GroundSmash): velocity.y = MaxAcc.y
		#endregion
		
		#region Set direction
		#Sprite direction
		Sprite.flip_h = false if LastDirection >= 0 else true
		$Wallchecker.rotation_degrees = 90 if LastDirection < 0 else -90
		#endregion
		
		#region Apply movement	
		if(direction != 0): LastDirection = direction
		
		was_on_floor = is_on_floor()
		
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
		if($"control_pause_menu"):
			$"control_pause_menu".queue_free()
			
		#Get timer and pause
		$"../Time_Left".paused = false	
		#Stop player movement
		Physics = true
		#Stop enemie movement
		EnemiesPhysics = true
		Pause_fadeout = false
		Paused = false

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
	$"control_pause_menu/pause_menu/Transition/AnimationPlayer".play("fade_movement")
	ReturnToGameTime.start()
	Pause_fadeout = true
	
func _spawn_pause_menu() -> void:
	var pause_menu = preload("res://assets/Levels/world1/pause_menu.tscn")
	if (pause_menu):
		var pause_menu_instance = pause_menu.instantiate()
		add_child(pause_menu_instance)
#endregion

# region Gravity
func _physics_apply_gravity(delta: float) -> void:
	if (!is_on_floor()):
		if(was_on_floor): CoyoteTimer.start()
		if(!WallJump && DashTime.is_stopped()):
			velocity.y += get_gravity_player() * Acc.y * delta
			if(!WallJump):
				if(velocity.y < 0): strech_size(0.7, 1.3)
				elif(velocity.y >= MaxAcc.y):
					strech_size(0.5, 1.7)
					#_play_sound(AudioWind, false)
		#else: velocity.y += Speed.y * delta
	if (is_on_floor()):
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

#region jump
func _physics_jump(delta: float) -> void:
	# Handle jump.
	if ((!PreJumpTime.is_stopped() && (is_on_floor() || WallJump || !CoyoteTimer.is_stopped()) ) || (!PreWallJumpTimer.is_stopped() && Input.is_action_pressed("player_jump")) ):
		DoJump()
	#Cancel jump
	if(velocity.y < 0 && !Input.is_action_pressed("player_jump")):
		velocity.y += JumpCancelAcc
	
	if(Input.is_action_pressed("player_jump")): PreJumpTime.start()
	
	#Pre-detect jump
#endregion

func DoJump() -> void:
	if(Sliding != Sides.NONE):
		Sliding = Sides.UP
		Speed.x = Acc.x*2 if LastDirection >= 0 else Acc.x*-2
	velocity.y = jump_velocity
	Controller_Vibrate_Player_Movement(0.2)
	_play_sound(AudioJump, false)
	#region WallJump case
	if(WallJump || !PreWallJumpTimer.is_stopped()):
		Speed.x = WallJumpVelocity*-1 if WallJumpPreviousSide == Sides.RIGHT else WallJumpVelocity
		PreWallJumpTimer.stop()
		velocity.y -= 50
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
		if(!is_on_floor() && !Slide && (Sliding != Sides.UP) ):# || velocity.y < jump_height+10)):
			velocity.y = SlideVelocity
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
	if(!Input.is_action_pressed("player_slide") && is_on_floor() ):
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
		Controller_Vibrate_Player_Movement(0.7)
	#Dash movement
	if(DashTime.is_stopped()):
		if(DashMove.x > 250): DashMove.x -= Acc.x * LastDirection 
		else: DashMove.x = 0
		if(DashMove.y > 250): DashMove.y -= Acc.y * LastDirection
		else: DashMove.y = 0
	#When dashing suspend in air
	else: velocity.y = 0
#endregion

#region WallJump
func _physics_walljump(delta: float) -> void:
	#The idea is to mantain some vertical movement, but still be able to jump more than before, like SuperMeatBoy
	var direction := Input.get_axis("ui_left", "ui_right")
	if(is_near_wall() && direction):
		Dashed = false
		velocity.y += 50*delta
		if(!WallJump): velocity.y = 50
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
func strech_size(X, Y):
	Sprite.scale = Vector2(original_scale.x*X, original_scale.y*Y)

func _strech_tick(delta : float):
	
	Sprite.scale.x += (original_scale.x - Sprite.scale.x) * 20 * delta
	Sprite.scale.y += (original_scale.y - Sprite.scale.y) * 20 * delta
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
	if(is_on_floor()): ParticlesDeathFloor.emitting = true
	else: ParticlesDeathAir.emitting = true
	Sprite.hide()
	Physics = false
	Dead = true
	#TransitionOut.show()
	#TransitionOut.fade_out()
	await(get_tree().create_timer(TimeDeath).timeout)
	if get_tree():
		get_tree().reload_current_scene()
#endregion

#region Wall Checker
func is_near_wall() -> bool:
	return $Wallchecker.is_colliding()
#endregion
