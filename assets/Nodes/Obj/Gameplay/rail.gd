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

@export var KickMult : float = 30
@onready var InitialCollisionArea = $InitialCollisionArea
@onready var InitialCollisionAreaShape = $InitialCollisionArea/CollisionShape2D

const AreaCollisionExpand : float = 100.0

func reload_path() -> void:
	var min_pos : Vector2 = points[0]
	var max_pos : Vector2 = points[0]
	#Esto todavia no esta porque la parte donde se centra la posicion esta mal hecha.
	#Basicamente lo que pasa es que el centro del node de rail no es el mismo que el de los puntos del line2d
	#hay que tener en cuenta que el tamaño de la colision se centra automaticamente
	#entonces lo que hice es 'desentrarlo', pero eso es solo una parte del problema
	#lo que queda ahora es centrarlo para la posicion del medio del otro
	#y eso se haria primero calculando el punto(que es igual al promedio de todos los demas puntos
	#y despues sumarle la distancia que tiene al mismo en cada eje
	Path.global_position = self.global_position
	Path.curve.clear_points()
	for point in points:
		if(point.x < min_pos.x): min_pos.x = point.x
		if(point.y < min_pos.y): min_pos.y = point.y
		if(point.x > max_pos.x): max_pos.x = point.x
		if(point.y > max_pos.y): max_pos.y = point.y
		Path.curve.add_point(point)
	InitialCollisionAreaShape.shape.size.x = abs(max_pos.x-min_pos.x)
	InitialCollisionAreaShape.shape.size.y = abs(max_pos.y-min_pos.y)
	InitialCollisionArea.position.x += abs(max_pos.x-min_pos.x)/2
	InitialCollisionArea.position.y -= abs(max_pos.y-min_pos.y)/2
	
	InitialCollisionAreaShape.shape.size.x += AreaCollisionExpand
	InitialCollisionAreaShape.shape.size.y += AreaCollisionExpand

func _ready() -> void:
	reload_path()

func _process(delta: float) -> void:
	print(PlayerInArea)
	#print(Player.velocity.x)
	if(Player):
		if(Player.OnWater):
			PathFollow.progress += MoveSpeed * delta * OnWaterSpeedMult
		else:
			PathFollow.progress += MoveSpeed * delta
		PlayerDistance = Path.curve.get_closest_point(to_local(Player.global_position))
		#if(PlayerDistance.distance_to(to_local(Player.global_position)) <= DistanceCollide):
			#print("Snappable")
		if(PlayerInArea && PlayerDistance.distance_to(to_local(Player.global_position)) <= DistanceCollide && !Player.SnappedOnRail && FallCooldown.is_stopped()):
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
			Player.KickSpeed.x = MoveSpeed*KickMult * KickDirection
			if(PathFollow.rotation_degrees >= 100.0): Player.KickSpeed.x *= -1
		else:
			Player.Speed.x = 0
	else:
		Player.GroundSmash = true
		Player.PressingGroundSmash = true

var PlayerInArea : bool = false

func _on_initial_collision_area_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")): PlayerInArea = true


func _on_initial_collision_area_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")): PlayerInArea = false
