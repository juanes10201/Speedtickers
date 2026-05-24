extends Line2D

@export var FallCooldown : Timer
@export var MoveRef : Node2D
@export var Path : Path2D
@export var PathFollow : PathFollow2D
@onready var Player = SaveGame.get_player()
var PlayerDistance : Vector2
@export var DistanceCollide : int = 7
var PlayerOffset : float
@export var MoveSpeed : float = 700
@export var OnWaterSpeedMult : float = 0.8
@export var PlayerMovOffset : Vector2 = Vector2(0.0, -5.0)
var PlayerSnapped : bool = false
@export var EndWithSlam : bool = false

@export var KickDirection : Global.GravityDirections = Global.GravityDirections.MAIN

func _ready() -> void:
	Path.global_position = self.global_position
	Path.curve.clear_points()
	for point in points:
		Path.curve.add_point(point)

func _process(delta: float) -> void:
	#print(Player.velocity.x)
	if(Player):
		if(Player.OnWater):
			PathFollow.progress += MoveSpeed * delta * OnWaterSpeedMult
		else:
			PathFollow.progress += MoveSpeed * delta
		PlayerDistance = Path.curve.get_closest_point(to_local(Player.global_position))
		#if(PlayerDistance.distance_to(to_local(Player.global_position)) <= DistanceCollide):
			#print("Snappable")
		if(PlayerDistance.distance_to(to_local(Player.global_position)) <= DistanceCollide && !Player.SnappedOnRail && FallCooldown.is_stopped()):
			if(Player.Slide || Player.GroundSmash):
				PlayerOffset = Path.curve.get_closest_offset(to_local(Player.global_position))
				PathFollow.progress = PlayerOffset
				Player.SnappedOnRail = true
				PlayerSnapped = true
				print("Player snapped on rail")
		if(Player.SnappedOnRail && PlayerSnapped):				
			Player.strech_size(1.0, 1.0, true, 20)
			Player.global_position = MoveRef.global_position + PlayerMovOffset
			Player.Sprite.rotation_degrees = PathFollow.rotation_degrees
			if(Input.is_action_just_pressed("player_jump")):
				EndPlayerRail(EndWithSlam, Player.jump_velocity * Player.GravityDirection, false)
			if(PathFollow.progress_ratio >= 1.0):
				EndPlayerRail(EndWithSlam)
			FallCooldown.start()

func EndPlayerRail(EndSlam : bool = false, VelY : float = 10.0, MoveX : bool = true) -> void:
	Player.global_position = MoveRef.global_position + PlayerMovOffset
	Player.SnappedOnRail = false
	PlayerSnapped = false
	Player.Sprite.rotation = 0.0
	Player.Reset_Slide()
	Player._fade_sound(Player.AudioRail)
	if(!EndSlam):
		Player.Reset_Groundsmash(false)
		Player.velocity.y = VelY
		if(MoveX):
			Player.KickTimer.start()
			Player.KickSpeed.x = MoveSpeed*30 * KickDirection
			if(PathFollow.rotation_degrees >= 100.0): Player.KickSpeed.x *= -1
		else:
			Player.Speed.x = 0
	else:
		Player.GroundSmash = true
		Player.PressingGroundSmash = true
