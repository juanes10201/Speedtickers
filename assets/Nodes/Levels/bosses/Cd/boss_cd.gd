extends CharacterBody2D

var Speed : Vector2 = Vector2(0.0, 0.0)
const MaxSpeed : Vector2 = Vector2(300.0, 100.0)
const Acc : Vector2 = Vector2(200.0, 120.0) 
const ChangeDirXVel : float = 30.0
const RadiusJump : float = 120.0

var MovingDir : Vector2 = Vector2(-1.0, 0.0)

@export_subgroup("Jump")
@export_range(0, 7000.0, .5, "or_greater", "or_less") var WallJumpVelocity : float = 7000.0
@export_range(0, 100, .5, "or_greater", "or_less") var jump_height : float = 90.0
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_peak : float = 0.7
@export_range(0, 1.0, .25, "or_greater", "or_less") var jump_time_to_descent : float = 0.2

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var Player = SaveGame.get_player()

@export var SlamTimeout : Timer

var Jumped : bool = false
const DistPlayerSlam : float = 15.0
var FallingSlam : bool = false

@export var ProyectileNoMove : Timer

@export var TimerShootCooldown : Timer
@export var ShootLines : Node2D
@export var TimeCooldownSlide : Timer

var Sliding : bool = false
const DistSlide : float = 300.0
const SlideVel : float = 400.0

const ShootAmount : int = 3.0
var ShootedLocations : Array[Vector2] = []

var PlayerPreviousPos : Vector2 = Vector2(0.0, 0.0)
var PlayerMoveRadius : float = 0.2
var PlayerShootTime : float = .5
const PlayerAfkTime : float = 0.5

@export var Boomerang : Area2D
@export var BoomerangTimer : Timer

@export var DiagonalShotRayCast : RayCast2D
@export var MidAirShotRayCast : RayCast2D

@export var BossLifeBar : ProgressBar
@export var ShieldLifeBar : ProgressBar
var BossLife : float = 80.0
var ShieldLife : float = 0.0

var Escaping : bool = false 

@export var AudioShoot : AudioStreamPlayer
@export var AudioLoad : AudioStreamPlayer
@export var AudioFall : AudioStreamPlayer

@export var DestroyTilemap : TileMapLayer

@export var CameraPlayer : Camera2D

@export var MarkerEscapePosition : Marker2D

func _ready() -> void:
	MovingDir.x = _calc_player_dir()
	_start_escape()
	#_shoot_proyectiles()

func _calc_player_dir() -> float:
	return ceil(clamp(Player.global_position.x - global_position.x, -1.0, 1.0))

func Shoot_all() -> void:
	ShootLines.shoot_all()

func _slide(delta : float) -> void:
	if(is_on_wall()):
		TimeCooldownSlide.start()
		Sliding = false
		ShootedLocations.clear()
		ShootLines.shoot_all()
	if(TimeCooldownSlide.is_stopped() && !Sliding && global_position.distance_to(Player.global_position) >= DistSlide ):
		Sliding = true
	if(Sliding):
		if(TimerShootCooldown.is_stopped()):
			if(ShootedLocations.size() < ShootAmount):
				#print("Shoot")
				TimerShootCooldown.start()
				var ShootPos : Vector2 = Player.global_position#Vector2(Player.global_position.x-ShootLines.global_position.x, Player.global_position.y-ShootLines.global_position.y)
				#ShootRaycast.target_position = Vector2(Player.global_position.x-ShootRaycast.global_position.x, Player.global_position.y-ShootRaycast.global_position.y)
				#ShootLine.points[1] = ShootRaycast.target_position
				ShootLines.add_line(ShootPos)
				ShootedLocations.append(ShootPos)
				Player._play_sound(AudioLoad)
			#else:
			#	Shoot_all()
		Speed.x = SlideVel * MovingDir.x
		#print(MovingDir)

func _movement_x(delta : float) -> void:
	#if(Jumped): return
	_slide(delta)
	if(!Sliding):
		if(is_on_floor()):
			MovingDir.x = _calc_player_dir()
		if(MovingDir.x):
			if(ceil(clamp(Speed.x, -1.0, 1.0) ) != MovingDir.x): Speed.x = lerpf(Speed.x, MovingDir.x, ChangeDirXVel*delta)
			if(abs(Speed.x) < abs(MaxSpeed.x)):
				Speed.x += Acc.x * MovingDir.x * delta
		else:
			Speed.x = lerpf(Speed.x, 0.0, Acc.x*delta)

func _movement_y(delta : float) -> void:
	if(is_on_floor()):
		FallingSlam = false
		Jumped = false
	if(!Sliding && !Jumped && global_position.distance_to(Player.global_position) <= RadiusJump): 
		Jumped = true
		velocity.y = jump_velocity
	velocity.y += get_gravity_player() * delta

func get_gravity_player() -> float:
	if(!SlamTimeout.is_stopped()): return 0.0
	if(!FallingSlam && SlamTimeout.is_stopped() && abs(global_position.x-Player.global_position.x) <= DistPlayerSlam):
		SlamTimeout.start()
	if(FallingSlam): return fall_gravity
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _shoot_pos(pos : Vector2, wait_time : float = 0.5) -> void:
	Player._play_sound(AudioLoad)
	ShootLines.add_line(pos)
	ShootedLocations.append(pos)
	await get_tree().create_timer(wait_time).timeout
	Shoot_all()
	ShootedLocations.clear()

func _predict_mov(global_pos : Vector2,vel : Vector2, time : float) -> Vector2:
	return Vector2(vel.x*time, vel.y*time)+global_pos

func _predict_player_mov(time : float) -> Vector2:
	if(Player):
		return _predict_mov(Player.global_position, Player.velocity, time)
	else: return Vector2(0.0, 0.0)

func _shoot_tick(delta : float) -> void:
	#print(PlayerShootTime)
	
	if(ShootedLocations.is_empty()):
		#Midair and diagonal shoot
		MidAirShotRayCast.target_position.x = abs(MidAirShotRayCast.target_position.x)*_calc_player_dir()
		DiagonalShotRayCast.target_position.x = abs(DiagonalShotRayCast.target_position.x)*_calc_player_dir()
		if(!Sliding):
			if(is_on_floor() && MidAirShotRayCast.is_colliding()):
				_shoot_pos(MidAirShotRayCast.target_position, .7)
			if(DiagonalShotRayCast.is_colliding()):
				_shoot_pos(_predict_player_mov(1.0), 1.0)
		
	#Timeout shoot
	if(abs(PlayerPreviousPos.y-Player.global_position.y)  <= PlayerMoveRadius): #PlayerPreviousPos.distance_to(Player.global_position) <= PlayerMoveRadius):
		if(PlayerShootTime <= 0.0 && !ShootedLocations && !Sliding):
			_shoot_pos(Player.global_position)
			PlayerShootTime = PlayerAfkTime
		else:
			PlayerShootTime -= 1*delta
	else:
		PlayerShootTime = PlayerAfkTime
	PlayerPreviousPos = Player.global_position

func _life_boss_tick(delta : float) -> void:
	BossLifeBar.value = BossLife
	ShieldLifeBar.value = ShieldLife
	if(BossLife <= 0):
		_start_escape()

func _start_escape() -> void:
	if(!Escaping):
		Escaping = true
		global_position = MarkerEscapePosition.global_position
		if(DestroyTilemap):
			DestroyTilemap.queue_free()

var ExtraSpeedX : float = 0.0
@export var EscapeMinSpeedX : float = 200.0
@export var EscapeMaxSpeedX : float = 300.0
@export var EscapeMaxDistance : float = 200.0
@export var EscapeMinDistance : float = 120.0
@export var EscapeKillDistance : float = 50.0
@export var EscapeMaxDistanceSpeed : float = 200.0

var EscapeCatchedPlayer : bool = false

@export var EscapeJumpRaycast : RayCast2D

func _escape_tick(delta : float) -> void:
	CameraPlayer.limit_right = lerpf(CameraPlayer.limit_right, 2000, 10*delta)
	CameraPlayer.zoom.x = lerpf(CameraPlayer.zoom.x, 1.45, 2*delta)
	CameraPlayer.zoom.y = lerpf(CameraPlayer.zoom.y, 1.45, 2*delta)
	
	Speed.x = Player.velocity.x
	Speed.x = clamp(Speed.x, EscapeMinSpeedX, EscapeMaxSpeedX)
	#Aumentar la velocidad al alejarse
	if(global_position.distance_to(Player.global_position) > EscapeMaxDistance ):
		ExtraSpeedX = lerpf(ExtraSpeedX, EscapeMaxDistanceSpeed, 2*delta)
	else: ExtraSpeedX = lerpf(ExtraSpeedX, 0.0, 3*delta)
	Speed.x += ExtraSpeedX
	
	#Caso de salto
	if(is_on_floor() && EscapeJumpRaycast.is_colliding()):
		velocity.y = jump_velocity
	velocity.y += get_gravity_player() * delta
	
	#Al estar demasiado cerca ir a la posicion del jugador
	if(EscapeCatchedPlayer || abs(global_position.x - Player.global_position.x) <= EscapeKillDistance):
		EscapeCatchedPlayer = true
		velocity.y = 0.0
		Speed.x = 0.0
		global_position.x = lerp(global_position.x, Player.global_position.x, 8*delta)
		global_position.y = lerp(global_position.y, Player.global_position.y, 8*delta)
	#Saltar al estar cerca del jugador
	elif(global_position.distance_to(Player.global_position) <= EscapeMinDistance && !Player._is_on_floor()):
		velocity.y = Player.velocity.y

func _physics_process(delta: float) -> void:
	_life_boss_tick(delta)
	if(ProyectileNoMove.is_stopped()):
		velocity.x = Speed.x
		if(Escaping):
			_escape_tick(delta)
		else:
			_movement_x(delta)
			_movement_y(delta)
			_shoot_tick(delta)
			_boomerang_tick(delta)
	else:
		velocity = Vector2(0.0, 0.0)
	#print(velocity) 
	move_and_slide()

@export var AudioAttackBoomerang : AudioStreamPlayer
func _boomerang_tick(delta : float) -> void:
	#print(BoomerangTimer.time_left)
	if(is_on_floor() && !Player._is_on_floor() && !Boomerang.Enabled && BoomerangTimer.is_stopped()):
		#Boomerang.enable()
		BoomerangTimer.start()
		Player._play_sound(AudioAttackBoomerang)

func _on_slam_timeout_timeout() -> void:
	FallingSlam = true

@export var ProyectileSpawner : Node

func _shoot_proyectiles() -> void:
	if(Escaping): return
	ProyectileSpawner.spawn_proyectiles()

func _on_proyectile_cooldown_timeout() -> void:
	if(Escaping): return
	_shoot_proyectiles()
	ProyectileNoMove.start()


func _on_proyectile_no_move_timeout() -> void:
	pass # Replace with function body.

func _on_shoot_cooldown_timeout() -> void:
	pass
	#Shoot_Bullet()
	#if(ShootedAmount < ShootAmount): Shoot_Bullet()
	#else:
	#	ShootedAmount = 0
	#	return


func _on_boomerang_cooldown_timeout() -> void:
	if(Escaping): return
	if(ProyectileNoMove.is_stopped()):
		Boomerang.enable()


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.On_Death()
