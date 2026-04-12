extends Area2D
@export var Activate_on_color : Global.LASER_COLORS = Global.LASER_COLORS.NONE
@export var InitialMarker : Marker2D
@export var EndMarker : Marker2D
@export var Speed : float = 0.5
enum direction{
	INITIAL = 1,
	RETURN = -1
}
@export var CurrentDir = direction.INITIAL
@onready var Sprite = $Sprite 

@export var DifChangeDir : float = 20.0

@export var HitSlamVel : Vector2 = Vector2(0.0, 700.0)
@export var HitSlamLerp : Vector2 = Vector2(0.0, 6)
@export var HitSlamVelGoTo : Vector2 = Vector2(0.0, -100.0)

@export var HitDashVel : Vector2 = Vector2(-820.0, 20.0)
@export var HitDashLerp : Vector2 = Vector2(7, 0.0)
@export var HitDashVelGoTo : Vector2 = Vector2(20.0, -20.0)
var FinalLerpDash : bool = false
@export var FinalLerpDashVel : float = -2.0

var HitSlam : bool = false
var HitDash : bool = false
var velocity : Vector2 = Vector2(0.0, 0.0)
@onready var CooldownDir = $CooldownDir

@export var WaterFloatLogic : Node2D

@onready var WaterTileset = SaveGame.get_group_node("WaterTileset")

@onready var Player : ClassPlayer = SaveGame.get_player()

@export var Enabled : bool = true
var EnabledMovement : bool = true

#region Editor
var EditorInitialPos : Vector2 = Vector2(0.0,0.0)

var InitialDirection : direction = direction.INITIAL

func cache_values_editor() -> void:
	EditorInitialPos = position
	InitialDirection = CurrentDir
	_ready()

func editor_reset() -> void:
	Sprite.visible = true
	Enabled = true
	for Child in get_children():
		if(Child is Timer):
			Child.stop()
		if(Child is GPUParticles2D || Child is CPUParticles2D):
			Child.emitting = false
	velocity = Vector2(0.0, 0.0)
	strech_size(1.0, 1.0)
	position = EditorInitialPos
	CurrentDir = InitialDirection
#endregion


func _set_rotation() -> void:
	if(!InitialMarker || !EndMarker): return
	var dir : Vector2 = EndMarker.global_position if CurrentDir == direction.INITIAL else InitialMarker.global_position
	look_at(dir)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(Activate_on_color != Global.LASER_COLORS.NONE):
		Enabled = false
	
	if($MoveEditorL && $MoveEditorR):
		$MoveEditorL.top_level = true
		$MoveEditorR.top_level = true
	elif(InitialMarker && EndMarker):
		var tmp_global = InitialMarker.global_position
		InitialMarker.top_level = true
		InitialMarker.global_position = tmp_global
		
		tmp_global = EndMarker.global_position
		EndMarker.top_level = true
		EndMarker.global_position = tmp_global
	
	_set_rotation()

func _hit_particles() -> void:
	$HitParticles1.emitting = true
	$HitParticles2.emitting = true
	$HitParticles3.emitting = true

func _slam_hit() -> void:
	HitSlam = true
	velocity = HitSlamVel
	EnabledMovement = false
	WaterFloatLogic.FallBelowWaterLevel = false
	_hit_particles()

func _dash_hit() -> void:
	strech_size(1.3, .7, true, 5)
	HitDash = true
	EnabledMovement = false
	velocity = HitDashVel
	if(Player):
		velocity.x *= Player.LastDirection * -1
		HitDashVelGoTo.x = abs(HitDashVelGoTo.x) * Player.LastDirection * -1
		FinalLerpDashVel = abs(FinalLerpDashVel) * Player.LastDirection * -1
	WaterFloatLogic.FallBelowWaterLevel = false
	FinalLerpDash = false
	_hit_particles()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_strech_tick(delta)
	if(!Enabled && Activate_on_color != Global.LASER_COLORS.NONE && Player.LASERS_ENABLED[Activate_on_color]):
		Enabled = true
	#print(velocity)
	if(Enabled && !(Edition.Is_in_editor && !Edition.Is_playing_in_editor)):
		if(HitDash):
			#if(abs(velocity.x) > 100.0):
			strech_size(1.2+1*clamp(abs(velocity.x), 0.0, 500)/500, 1.2+1*clamp(abs(velocity.x), 0.0, 500)/500, true)
			position += velocity*delta
			rotation_degrees = lerpf(rotation_degrees, 0.0, .05*delta)
			if(abs(velocity.x-HitDashVelGoTo.x) <= 10.0):
				FinalLerpDash = true
			if(!FinalLerpDash):
				velocity.x = lerpf(velocity.x, HitDashVelGoTo.x, delta*HitDashLerp.x)
			else:
				velocity.x = lerpf(velocity.x, FinalLerpDashVel, delta*HitDashLerp.x/5)
			velocity.y = lerpf(velocity.y, HitDashVelGoTo.y, delta*HitSlamLerp.y)
			WaterFloatLogic.float_logic(delta)
		elif(HitSlam):
			rotation_degrees = lerpf(rotation_degrees, 180.0, .05*delta)
			#if(velocity.y > 100.0):
			strech_size(1.1 + .5*clamp(abs(velocity.y), 0.0, 200)/200, 1.0-.3*clamp(abs(velocity.y), 0.0, 100)/100, true)
			position += velocity*delta
			velocity.x = lerpf(velocity.x, HitSlamVelGoTo.x, delta*HitSlamLerp.x)
			velocity.y = lerpf(velocity.y, HitSlamVelGoTo.y, delta*HitSlamLerp.y) 
			WaterFloatLogic.float_logic(delta)
		elif(EnabledMovement):
			WaterFloatLogic.float_logic(delta)
			if(!InitialMarker || !EndMarker): return
			var dir : Vector2 = EndMarker.global_position if CurrentDir == direction.INITIAL else InitialMarker.global_position
			dir.y = max(dir.y, WaterTileset.WaterLevel)
			global_position.x = lerpf(global_position.x, dir.x, Speed*delta)
			global_position.y = lerpf(global_position.y, dir.y, Speed*delta)
			#print("dir: " + str(dir.y))
			#print("water level: " + str(WaterTileset.WaterLevel))
			if(CooldownDir.is_stopped() && position.distance_to(dir) <= DifChangeDir):
				CurrentDir *= -1
				CooldownDir.start()
				_set_rotation()


func _on_body_entered(playerbody: Node2D) -> void:
	if(playerbody.is_in_group("Player")):
		if(playerbody.GroundSmash):
			_slam_hit()
			return
		#if(!playerbody.DashTime.is_stopped()):
		#	_dash_hit()
		if(EnabledMovement): playerbody.On_Death()

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
