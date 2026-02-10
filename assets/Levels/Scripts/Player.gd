extends CharacterBody2D
class_name ClassPlayer

func enemy_jump():
	pass

#region Variable defining
enum Sides{
	LEFT = -1,
	RIGHT = 1,
	NONE,
	UP
}

var SlidingInAir : bool = false
var EnableMovement : bool = true

var MoveLava : bool = false

var Sliding: Sides = Sides.NONE
var WasSliding : bool = false
var Slide : bool = false

var GroundSmashMultiplier : int = 1
var GroundSmashMultiplierLimit : int = 2
@onready var SlamStorageTimer : Timer = $SlamStorageTimer
var GroundSmash : bool = false
var WasGroundSmash : bool = false
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
var DashWithJump : bool = false
var DashedWithJump : bool = false

var LASERS_ENABLED : Array[bool] = [false, false, false, false, false]

var HaveKey : bool = false

var SnappedOnRail : bool = false

#region Export variables
@export var EnableParticles : bool = true
@export var RetroStyle : bool = false
@export var PlayIntro : bool = false
var juice : bool = true
@export var Styleometter : bool = true 
@export var CountTime : bool = true
@export_group("Physics")
@export var Physics : bool = true
@export var Acc_Multiplier : float = 1
@onready var InvencibilityTimer : Timer = $InvencibilityTimer

@export_subgroup("Jump")
@export_range(0, 7000.0, .5, "or_greater", "or_less") var WallJumpVelocity : float = 7000.0
@export_range(0, 100, .5, "or_greater", "or_less") var jump_height : float = 70.0
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_peak : float = 0.5
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_descent : float = 0.4

@export_subgroup("Groundsmash || Slide")
@export var GroundSmashVelocity = 600

@export_range(0, 25000.0, .5, "or_greater", "or_less") var SlideInitialVelocity : float = 25000.0
@export var SlideAcc = 6000
var SlideVelocity = 0

@export_range(0, 25.0, .5, "or_greater", "or_less") var JumpCancelAcc : float = 25.0

@export_subgroup("Death")
@export_range(0, 1.5, .25, "or_greater", "or_less") var TimeDeath : float = 1.5

@export_group("Level")
@export var EnemiesPhysics : bool = true

@export_group("Music")
@export var PlayMusic : bool = true
#endregion

var Paused : bool = false

@onready var ReturnToGameTime = $ReturnToGameTime


var LastDirection : float = 1
var direction = get_axis()

@onready var DashCooldownTimer : Timer = $DashCooldownTimer
@onready var CeilingMovementMultiplierTimer : Timer = $CeilingMovementMultiplierTimer
@onready var JumpGroundsmashMultiplier : Timer = $JumpGroundsmashMultiplier
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

@onready var AudioRail : AudioStreamPlayer = $AudioRail
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
@onready var AudioSandFall : AudioStreamPlayer = $AudioSandFall
@onready var AudioUpgrade : AudioStreamPlayer = $AudioUpgrade

@onready var AudioClockBreak : AudioStreamPlayer = $AudioClockBreak

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
@onready var SlamParticles1 = $"SlamParticles1"

@onready var SlideDestroyTiles = $"SlideDestroyTiles"
@onready var SlamDestroyTiles = $"SlamDestroyTiles"
@onready var RailDestroyTiles = $"RailDestroyTiles"

#@onready var OriginalCameraY : float = Camera.offset.y if Camera else 0

var Pause_fadeout : bool = false
var OnSand : bool = false
var was_on_floor : bool = true
var was_on_floor_raycast : bool = true
var Dead : bool = false

var EnabledKillBox : Global.KillBoxTypes = Global.KillBoxTypes.Red

@onready var OriginalPos : Vector2 = self.position

var GravityDirection : Global.GravityDirections = Global.GravityDirections.MAIN
var GravitySandFallDirection : Global.GravityDirections = Global.GravityDirections.MAIN

var SwitchedGravity : bool = false
var PlayedSwitchedGravityAnimation : bool = false

@export var Particles : bool = true

@onready var Time_Left : Timer = $"../Time_Left"

var KickSpeed : Vector2 = Vector2(0.0,0.0)
@onready var KickTimer : Timer = $KickTimer

enum AirSides{
	Jumping = 1,
	Falling = 2,
	NONE = 0
}

var AirState : AirSides = AirSides.NONE

#endregion

func _play_dash_particles():
	if(Particles):
		DashParticles1.emitting = true
func _stop_dash_particles():
	DashParticles1.emitting = false

func _play_slam_particles():
	if(Particles):
		SlamParticles1.emitting = true
func _stop_slam_particles():
	SlamParticles1.emitting = false



@export_group("Recording")
@onready var Replay = $System_replay
@export var ReplayAction : Global.ReplayStates = Global.ReplayStates.STOPPED
@export var ReplayStyle : bool = false
var RecordedActions : Array[Vector3] = []
@export var RecordedLocation : String = "res://assets/Replays/tutorial_level1_1.json"


func array_to_vec3(arr: Array) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for a in arr:
		out.append(Vector3(a[0], a[1], a[2]))
	return out

func _load_replay(Location : String) -> void:
	var file = FileAccess.open(Location, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_ARRAY:
			RecordedActions = array_to_vec3(data)
		else:
			push_error("Invalid JSON structure")

func _save_replay(Location : String) -> void:
	var json_array = RecordedActions.map(func(v): return [v.x, v.y, v.z])

	var file := FileAccess.open(Location, FileAccess.WRITE)
	file.store_string(JSON.stringify(json_array, "\t"))
	print("Saved Replay Json")

#region Debug
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			LevelManager.ExpoMoveTimeout.start()
			LevelManager.ExpoMoveTimeout.paused = true
			var _scene_string = "res://assets/Levels/world1/main_menu_expo_video.tscn"
			get_tree().change_scene_to_file(_scene_string)
		elif event.keycode == KEY_F9:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_F10:
			LevelManager.ExpoMoveTimeout.start()
			LevelManager.ExpoMoveTimeout.paused = true
			var _scene_string = "res://assets/Levels/world1/main_menu_w_level_preview.tscn"
			get_tree().change_scene_to_file(_scene_string)
		elif event.keycode == KEY_F11:
			LevelManager.ExpoMoveTimeout.start()
			LevelManager.ExpoMoveTimeout.paused = true
			var _scene_string = "res://assets/Levels/world1/select_level_world1.tscn"
			get_tree().change_scene_to_file(_scene_string)
		elif event.keycode == KEY_F12:
			LevelManager.ReturnAfterTimerInExpo = !LevelManager.ReturnAfterTimerInExpo
		elif event.keycode == KEY_F2:
			LevelManager.StyloMetter += 100
		elif event.keycode == KEY_F3:
			LevelManager.StyloMetter -= 100
		elif event.keycode == KEY_F4:
			if(ReplayAction != Global.ReplayStates.STOPPED):
				_save_replay("res://assets/Replays/saved_replay.json")
#endregion

func _ready() -> void:
	if(RetroStyle):
		ParticlesSlide.fixed_fps = 15
		ParticlesSlide.interpolate = false
		ParticlesJump.fixed_fps = 15
		ParticlesJump.interpolate = false
		ParticlesDeathFloor.fixed_fps = 15
		ParticlesDeathFloor.interpolate = false
		ParticlesDeathAir.fixed_fps = 15
		ParticlesDeathAir.interpolate = false
	if(ReplayAction == Global.ReplayStates.REPLAY):
		_load_replay(RecordedLocation)
	if(SaveGame.get_config_value("Particles") != null):
		Particles = SaveGame.get_config_value("Particles")
	if(SaveGame.get_config_value("Juice") != null):
		juice = SaveGame.get_config_value("Juice")
	Engine.time_scale = 1
	if(LevelManager.StyleTimer.is_stopped()): 
		LevelManager.ExpoMoveTimeout.paused = false
		LevelManager.StyleTimer.start()
	
	if(Physics && Edition.Mobile):
		var MobileControls = preload("res://assets/Levels/ui_android_control.tscn")
		if (MobileControls != null):
			var MobileControlsInstance = MobileControls.instantiate()
			if(MobileControlsInstance != null): UI.add_child(MobileControlsInstance)
	if(SaveGame.PlayedIntro() && Edition.GAME_STATUS != Edition.ALL_GAME_STATUS.expo_cbb): PlayIntro = false
	if(PlayIntro):
		#If level is not identified search for it
		SaveGame.PlayedIntroBool = true
		Global.Level = 0
		$TimerIntroSlam.start()
		Physics = false
		Sprite.hide()
	
	if(TransitionOut): TransitionOut.hide()
	if(TransitionIn): TransitionIn.show()
	if(TransitionIn): TransitionIn.fade_out()
	
	if(PlayIntro):
		$Camera2D/AnimationPlayer.play("Start")
		#Camera.offset.y = $Camera2D/InitialPoint.global_position.y
		FrameFreeze(.4, 2)
	
	#region Change music style to ingame
	if(PlayMusic):
		SongPlayer.MusicState = SongPlayer.MusicStates.ingame
	#endregion
	
#region Physics proccess
func _physics_process(delta: float) -> void:
	SlideDestroyTiles.target_position.x = abs(SlideDestroyTiles.target_position.x)
	if(LastDirection < 0): SlideDestroyTiles.target_position.x *= -1
	if(ReplayStyle):
		Sprite.modulate.a = 0.7
		Particles = false
		
	#if(Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo_cbb):
	#	print("time left: " + str(LevelManager.ExpoMoveTimeout.time_left))
	if(Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo_cbb && LevelManager.ExpoMoveTimeout.is_stopped()):
		LevelManager.ExpoMoveTimeout.start()
		LevelManager.ExpoMoveTimeout.paused = true
		var _scene_string = "res://assets/Levels/world1/main_menu_w_level_preview.tscn"
		get_tree().change_scene_to_file(_scene_string)
	
	if(_is_on_floor()):
		DashedWithJump = false
		SlidingInAir = false
		SwitchedGravity = false
		PlayedSwitchedGravityAnimation = false
	#region Set direction
	#Sprite direction
	Sprite.flip_h = false if LastDirection >= 0 else true
	$Wallchecker.rotation_degrees = 90 if LastDirection < 0 else -90
	_pause_menu_end_tick()
	#endregion
	#if(PlayIntro):
	#	Camera.offset.y = lerpf(Camera.offset.y, OriginalCameraY, .6*delta)
	if(Physics && !SnappedOnRail):
		LevelManager.ExpoMoveTimeout.paused = false
		if(velocity.y > 0):
			AirState = AirSides.Falling
		elif(velocity.y < 0):
			AirState = AirSides.Jumping
		else:
			AirState = AirSides.NONE
		
		WasSliding = false
		var direction = get_axis()
		
		if(GroundSmash):
			_play_slam_particles()
		else:
			_stop_slam_particles()
		
		if(SlidingOnRamp && !_is_on_floor()): velocity.y = GroundSmashVelocity * GravityDirection
		
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
		elif(AirState == AirSides.Falling && !_is_on_floor_raycast()):
			if(!Sprite.animation == "Jump"):
				Sprite.offset_play("Jump")
		elif(AirState == AirSides.Jumping && !_is_on_floor_raycast()):
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
		if(!_is_on_floor_raycast() && was_on_floor_raycast):
			Reset_Slide()
			if(!ParticlesLanding.is_playing()):
				ParticlesLanding.position = self.position
				ParticlesLanding.position.y -= 5
				ParticlesLanding.set_as_top_level(true)
				ParticlesLanding.play("default")
				ParticlesLanding.show()
			if(!ParticlesLanding.is_playing()):
				ParticlesLanding.hide()
		#endregion  
		
		if(_is_on_floor_raycast() && !was_on_floor_raycast):
			strech_size(1.7, 0.5)
			ParticlesJump.emitting = false
			ParticlesLanding.hide()
		if(!_is_on_floor_raycast() && Particles):
			ParticlesJump.emitting = true
		#endregion
		_strech_tick(delta)
		_physics_jump(delta)
		_physics_apply_gravity(delta)
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
		if(Acc.x * GravityDirection > MaxAcc.x): Acc.x = MaxAcc.x * GravityDirection * GravitySandFallDirection
		if(velocity.y * GravityDirection > MaxAcc.y && !GroundSmash): velocity.y = MaxAcc.y * GravityDirection * GravitySandFallDirection
		#endregion
		
		#region Apply movement	
		if(direction != 0): LastDirection = direction
		
		was_on_floor = _is_on_floor()
		was_on_floor_raycast = _is_on_floor_raycast()
		
		#region Sand Sound
		if(OnSand && !Slide): _play_sound(AudioWalkSand, false)
		else: _stop_sound(AudioWalkSand)
		#endregion
		
		#When touching ceiling granted to player *1.3 multiplier in x movement, so that the player doesn't get stuck
		if(_is_on_ceiling()):
			CeilingMovementMultiplierTimer.start()
		if(!CeilingMovementMultiplierTimer.is_stopped()): velocity.x *= 1.3
		
		if(DashTime.is_stopped() && !GroundSmash):
			velocity.x += KickSpeed.x * delta
		if(KickTimer.is_stopped()):
			KickSpeed.x = lerpf(KickSpeed.x, 0, delta*7)
		
		# Move the character
		move_and_slide()
		#endregion
	elif(SnappedOnRail):
		_play_sound(AudioRail, false, true, .3)
		Sprite.play("Rail")
		_Destroy_Tiles_Slide()
		_Destroy_Tiles_Rail()
		#_physics_jump(delta)
		#move_and_slide()
		
#endregion

#region Walking sound
func _play_sound(body, override : bool = true, pitch_scale: bool = true, gain : float = 1, pitch : float = 1, min_pitch : float = .8, min_time_change : float = 0.0, max_pitch : float = 1.0):
	if(body):
		if(override && body.playing && body.get_playback_position() >= min_time_change):
			body.stop()
		if(!body.playing):
			if(body == AudioSlide): body.volume_db = -10
			body.volume_db = gain
			if(pitch_scale): body.pitch_scale = randf_range(min_pitch, max_pitch)*pitch
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
		Time_Left.paused = false	
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
		Time_Left.paused = true	
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
			velocity.y += get_gravity_player() * Acc.y * delta * GravityDirection * GravitySandFallDirection
			if(!WallJump):
				if(velocity.y*GravityDirection < 0 && !_is_on_floor_raycast()): 
					strech_size(0.7, 1.2, true)
				elif(velocity.y*GravityDirection >= MaxAcc.y && !_is_on_floor_raycast()):
					strech_size(0.7, 1.3, true)
					#_play_sound(AudioWind, false)
		#else: velocity.y += Speed.y * delta
	if (_is_on_floor()):
		Dashed = false
		_stop_sound(AudioWind)
		#DashWithJump = false
		DashWithJump = false
		if(GroundSmash):
			Reset_Groundsmash()
		if(SlidingInAir):
			Sliding = Sides.NONE
			Slide = false
#endregion

#region Invert Gravity
func _change_gravity_decal() -> void:
	SwitchedGravity = true
	velocity.y = 100 * GravityDirection
	Dashed = false
	strech_size(1.5, 1.2)
	if(Particles): $ParticlesOrb.emitting = true
	_play_sound(AudioOrbGravity, true)

func _invert_gravity() -> void:
	GravityDirection *= -1
	_change_gravity_decal()

var GlobalGravityDirection = Global.GravityDirections.MAIN

func _invert_gravity_remix() -> void:
	GlobalGravityDirection *= -1

#endregion

#region jump
func _physics_jump(delta: float) -> void:
	# Handle jump.
	DashWithJump = false
	if ((!PreJumpTime.is_stopped() && (_is_on_floor() || WallJump || !CoyoteTimer.is_stopped()) ) || (!PreWallJumpTimer.is_stopped() && is_action_pressed("player_jump")) ):
		SnappedOnRail = false
		DoJump()
		LevelManager.ExpoMoveTimeout.start()
	#Cancel jump
	if(velocity.y < 0 && !is_action_pressed("player_jump") && !DashWithJump):
		velocity.y += JumpCancelAcc * GravityDirection
	
	if(is_action_pressed("player_jump")):
		SnappedOnRail = false
		LevelManager.ExpoMoveTimeout.start()
		PreJumpTime.start()
	
	#Pre-detect jump
#endregion

func DoJump() -> void:
	#Slide + Jump combo
	if(Sliding != Sides.NONE):
		SlidingInAir = true
		Speed.x = Acc.x*3 * ceil(LastDirection)
	velocity.y = jump_velocity * GravityDirection
	if(!DashTime.is_stopped() || DashWithJump):
		DashWithJump = true
		if(!DashedWithJump):
			LevelManager.AddStyle(0, "Dash with Jump Combo")
		DashedWithJump = true
		velocity.y *= .5
		DashMove *= 2
	#En caso de haber aplicado antes un groundsmash hacer un multiplicador de velocidad
	if(!JumpGroundsmashMultiplier.is_stopped()):
		JumpGroundsmashMultiplier.start()
		velocity.y *= 1.2
	Controller_Vibrate_Player_Movement(0.2)
	_play_sound(AudioJump, false)
	#region WallJump case
	if(WallJump || !PreWallJumpTimer.is_stopped()):
		if(GroundSmash):
			GroundSmash = false
			DidSlamStorage = false
			SlamStorageTimer.start()
			velocity.y = 0
			PressingGroundSmash = false
			if(GroundSmashMultiplier < GroundSmashMultiplierLimit):
				GroundSmashMultiplier += 1.1
		Speed.x = WallJumpVelocity*-1 if WallJumpPreviousSide == Sides.RIGHT else WallJumpVelocity
		PreWallJumpTimer.stop()
		velocity.y -= 50 * GravityDirection
		if($ParticleWalljump && !$ParticleWalljump/ParticleWallJumpAnim.is_playing()):
			#print(WallJumpSide)
			$ParticleWalljump.position = position
			$ParticleWalljump.position.x -= 6.0
			#if(WallJumpSide == 1):
			#	$ParticleWalljump.position.x -= 8.0
			$ParticleWalljump/ParticleWallJumpAnim.play("Walljump")
			$ParticleWalljump/ParticleWalljump1.play("default")
			$ParticleWalljump/ParticleWalljump2.play("default")
	#endregion

#region Horizontal movement
func _physics_h_movement(delta: float) -> void:
	var direction = get_axis()
	if(abs(direction) > 0.4): LevelManager.ExpoMoveTimeout.start()
	# Fix the Movement Speed accumulating in the side touching a wall
	if(WallJump && WallJumpSide == Sides.RIGHT && Speed.x > 0): Speed.x = 0
	if(WallJump && WallJumpSide == Sides.LEFT && Speed.x < 0): Speed.x = 0
	
	# Get the input direction and handle the movement/deceleration.
	if (!WallJump && direction && Speed.x < MaxAcc.x && Speed.x > MaxAcc.x*-1):
		#_play_sound(AudioWalk, false)
		if((direction > 0 && Speed.x < 0) || (direction < 0 && Speed.x > 0)): Speed.x += Acc.x * direction
		#Move faster if coming from Walljump
		if((WallJumpPreviousSide == Sides.LEFT && direction < 0) || (WallJumpPreviousSide == Sides.RIGHT && direction > 0) && !PreWallJumpTimer.is_stopped()): Speed.x += Acc.x * direction *2
		
		Speed.x += Acc.x * direction * Acc_Multiplier  # Adjust speed based on input direction
	else:
		if(Speed.x > 0): Speed.x -= Acc.x
		if(Speed.x < 0): Speed.x += Acc.x
		#_stop_sound(AudioWalk)
#endregion

var PressedSlide : bool = false
var DidSlamStorage : bool = false
var DidDiagonalSlam : bool = false

#region Slide and Ground Smash
func _physics_slide_and_groundsmash(delta: float) -> void:
	if(GroundSmash):
		_Destroy_Tiles_Slam()
	if(!is_action_pressed("player_slide")):
		SlidingInAir = false
		#LevelManager.ExpoMoveTimeout.start()
	if((is_action_pressed("player_slide") || PressingGroundSmash)):
		LevelManager.ExpoMoveTimeout.start()
		#Groundsmash/Slam
		if(!_is_on_floor_raycast() && !Slide && !SlidingInAir && !PressedSlide):# || velocity.y < jump_height+10)):
			if(!GravityDirection): GravityDirection = Global.GravityDirections.MAIN
			velocity.y = GroundSmashVelocity * GravityDirection
			#Slam Storage
			if(!SlamStorageTimer.is_stopped()):
				if(!DidSlamStorage):
					DidSlamStorage = true
					LevelManager.AddStyle(1, "Slam Storage")
				velocity.y *= GroundSmashMultiplier
			GroundSmash = true
			if(!DashTime.is_stopped() && !DidDiagonalSlam):
				LevelManager.AddStyle(0, "Diagonal Groundsmash")
				DidDiagonalSlam = true
			PressingGroundSmash = true
			set_collision_mask_value(4, false)
		#Slide
		elif(!SlidingInAir && !PressingGroundSmash):
			_Destroy_Tiles_Slide()
			if(SlideVelocity == 0): SlideVelocity = SlideInitialVelocity
			#SlideVelocity += SlideAcc * delta
			PressedSlide = true
			
			_play_sound(AudioSlide, false)
			Controller_Vibrate_Player_Movement(0.2)
			Speed.x = SlideVelocity * Sliding
			#if(SlidingOnRamp): Speed.x *= 1.2
			if(Sliding == Sides.NONE): Sliding = Sides.RIGHT if LastDirection > 0  else Sides.LEFT
			Slide = true
			if(Particles): ParticlesSlide.emitting = true
			strech_size(1, .9)
			Sprite.play("Slide")
			set_collision_mask_value(3, false)
		elif(Slide && velocity.y < 0):
			Speed.x = SlideVelocity * Sliding
	elif(Sliding != Sides.NONE):
		Reset_Slide()
		Speed.x = 0
	
	if(!is_action_pressed("player_slide")): PressedSlide = false
	
	#if(!SlidingInAir):
		#strech_size(1, 1)
	if(!Slide): set_collision_mask_value(3, true)
	if(!GroundSmash): set_collision_mask_value(4, true)
	if(!is_action_pressed("player_slide") && _is_on_floor() ):
		PressingGroundSmash = false

func Reset_Slide():
	_fade_sound(AudioSlide)
	Sliding = Sides.NONE
	ParticlesSlide.emitting = false
	Slide = false
	#if(!SlidingInAir):
		#Speed.x = 0
	SlideVelocity = 0

	#endregion

#region Dash
func _physics_dash(delta: float) -> void:
	#Dash
	if(is_action_pressed("player_dash") && !Dashed && DashCooldownTimer.is_stopped()):
		DashCooldownTimer.start()
		if(Slide): LevelManager.AddStyle(0, "Slide Dash")
		LevelManager.ExpoMoveTimeout.start()
		velocity.y = 0
		Dashed = true
		AudioDash.pitch_scale = randf_range(0.8, 1.2)
		AudioDash.play()
		strech_size(2.5, 0.5)
		DashTime.start()
		DashMove = DashAcc * ceil(LastDirection)
		Controller_Vibrate_Player_Movement(0.7)
	#Dash movement
	if(DashWithJump): DashMove = DashAcc * LastDirection
	if(DashTime.is_stopped()):
		if(DashMove.x > 250): DashMove.x -= Acc.x * LastDirection
		else: DashMove.x = 0
		if(DashMove.y > 250): DashMove.y -= Acc.y * LastDirection
		else: DashMove.y = 0
	#La idea es que al ejecutar un dash el movimiento vertical este suspendido
	elif(SwitchedGravity): velocity.y = 0
#endregion


#region WallJump
func _physics_walljump(delta: float) -> void:
	#The idea is to mantain some vertical movement, but still be able to jump more than before, like SuperMeatBoy
	direction = get_axis()
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
#andino was here
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
	if(Physics && InvencibilityTimer.is_stopped()):
		LevelManager.RemoveStyle(100)
		if(_is_on_floor_raycast() && Particles): ParticlesDeathFloor.emitting = true
		elif(Particles): ParticlesDeathAir.emitting = true
		Sprite.hide()
		Physics = false
		Dead = true
		_play_sound(AudioDeath, true)
		#TransitionOut.show()
		#TransitionOut.fade_out()
		if(!Edition.Is_in_editor && ReplayAction == Global.ReplayStates.STOPPED):
			await(get_tree().create_timer(TimeDeath).timeout)
			if get_tree():
				get_tree().reload_current_scene() 
#endregion

func _Destroy_Tiles_Rail() -> void:
	_Raycast_Destroy_Tiles(RailDestroyTiles)

func _Destroy_Tiles_Slide() -> void:
	_Raycast_Destroy_Tiles(SlideDestroyTiles)

func _Destroy_Tiles_Slam() -> void:
	_Raycast_Destroy_Tiles(SlamDestroyTiles)

func _Raycast_Destroy_Tiles(Raycaster : RayCast2D) -> void:
	if(ReplayStyle): return
	Raycaster.enabled = true
	if(Raycaster.is_colliding()):
		var hit_collider = Raycaster.get_collider()
		if hit_collider.get_class() == "TileMapLayer":
			var tilemap = hit_collider
			var hit_pos_global = Raycaster.get_collision_point()
			var hit_pos_local = tilemap.to_local(hit_pos_global)
			var tile_pos: Vector2i = tilemap.local_to_map(hit_pos_local)
			tilemap.set_cell(tile_pos, -1)
			
			print("Destroyed tile: " + str(tile_pos))
			
			var DestroyParticles = preload("res://assets/Levels/world1/ParticleBreakGlass.tscn")
			var InstanceParticles = DestroyParticles.instantiate()
			get_tree().current_scene.add_child(InstanceParticles)
			InstanceParticles.position = self.position
			print(tile_pos)
			if(randf() > .7):
				_play_sound($AudioGlassBreak_part1, true, true, -5, 1, .9, .1)
			if(randf() > .4):
				_play_sound($AudioGlassBreak_part2, true, true, -5, 1, .7, 0.0)
			_play_sound($AudioGlassBreak_part3, true, true, -5, 1, .7, 0.2)
			_play_sound($AudioGlassBreak_part4, true, true, -5, 1, .7, .1)
			_play_sound($AudioGlassBreak_part5, true, true, -5, 1, .8, .1)
			LevelManager.AddStyle(0, "Broke Glass")


@onready var GroundRaycast : RayCast2D = $GroundRaycast
func _is_on_floor_raycast() -> bool:
	GroundRaycast.enabled = true
	return GroundRaycast.is_colliding()

func _is_on_floor() -> bool:
	if(GravityDirection == Global.GravityDirections.MAIN):
		return is_on_floor()
	else:
		return is_on_ceiling()

func _is_on_ceiling() -> bool:
	if(GravityDirection == Global.GravityDirections.INVERTED):
		return is_on_floor()
	else:
		return is_on_ceiling()

#region Wall Checker
func is_near_wall() -> bool:
	return $Wallchecker.is_colliding()
#endregion

func is_action_pressed(Action : String):
	if(!EnableMovement): return
	if(ReplayAction != Global.ReplayStates.REPLAY):
		return Input.is_action_pressed(str(Action))
	elif(Replay):
		return Replay.ReplayActions[Action]

func get_axis():
	if(!EnableMovement): return 0
	if(ReplayAction != Global.ReplayStates.REPLAY):
		return Input.get_axis("ui_left", "ui_right")
	elif(Replay):
		if(Replay.ReplayActions["ui_left"]): return -1
		if(Replay.ReplayActions["ui_right"]): return 1
		else: return 0

func Reset_Groundsmash(ThrowEnemies : bool = true) -> void:
	PressingGroundSmash = false
	ParticlesLanding.position = self.position
	ParticlesLanding.position.y -= 10
	ParticlesLanding.set_as_top_level(true)
	ParticlesLanding.play("groundsmash")
	ParticlesLanding.show()
	AudioGroundsmash.play()
	GroundSmash = false
	DidSlamStorage = false
	DidDiagonalSlam = false
	GroundSmashMultiplier = 1
	JumpGroundsmashMultiplier.start()
	if(Camera): Camera.Shake(10.0, 10.0)
	if(ThrowEnemies):
		enemy_jump()
		EnemyGroundSlamTimer.start()
	velocity.y = 0


func _on_timer_intro_slam_timeout() -> void:
	Physics = true
	Sprite.show()
	Input.action_press("player_slide")
	await get_tree().create_timer(.5).timeout
	Input.action_release("player_slide")
