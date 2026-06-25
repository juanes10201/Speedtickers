extends PathFollow2D

@onready var Line : Line2D = get_parent().get_parent()
@onready var Path : Path2D = get_parent()
@export var Enabled : bool = true
@export var CooldownAnim : bool = true

@export var CooldownTimer : Timer
@onready var OriginalRatio : float = progress_ratio

@onready var previous_ratio : float = progress_ratio

enum Types {
	None,
	Horizontal,
	HorizontalChangeDir,
	Piston
}
@export var Type : Types = Types.Horizontal
@onready var Player = SaveGame.get_player()

var Direction : float = 1.0
@export var RigidBody : RigidBody2D
@onready var CollisionShape : CollisionShape2D = RigidBody.get_node("Collision")
@onready var SizeX : float = CollisionShape.shape.size.x if CollisionShape else 16.0

@onready var LastGlobalPosition : Vector2 = global_position
@export var ChangeGlobalSpeed : bool = false

const InLineMargin : float = 10.0
var Falling : bool = false

@export var InitialWaitTime : float = .5
@export var InitialWaitTimer : Timer

func _ready() -> void:
	if(InitialWaitTimer && InitialWaitTime != 0.0):
		InitialWaitTimer.wait_time = InitialWaitTime
		InitialWaitTimer.start()
	if(PistonSwitchDirTimer): PistonSwitchDirTimer.wait_time = PistonCooldownTime
	if(Enabled):
		restart()

func restart() -> void:
	#print("Restart")
	if(Type == Types.None): return
	if(!Enabled || progress_ratio >= OriginalRatio):
		Enabled = true
		if(Type == Types.HorizontalChangeDir): return

func _set_shader_to_timer(timer : Timer, node : Node):
	node.material.set_shader_parameter("progress", 1-(timer.time_left/timer.wait_time) )

func _reload_material_shader() -> void:
	for Child in get_children():
		if(Child is RigidBody2D):
			if(InitialWaitTimer && !InitialWaitTimer.is_stopped() ):
				_set_shader_to_timer(InitialWaitTimer, Child)
			elif(PistonSwitchDirTimer && !PistonSwitchDirTimer.is_stopped() ):
				_set_shader_to_timer(PistonSwitchDirTimer, Child)
			elif(!CooldownTimer.is_stopped()):
				_set_shader_to_timer(CooldownTimer, Child)
			else:
				Child.material.set_shader_parameter("progress", 0.0 )
var PreviousTan : int = 1
func get_tangent() -> int:
	#var curve = get_parent().curve
	#var p1 = curve.sample_baked(progress - 1.0)
	#var p2 = curve.sample_baked(progress + 1.0)
	#if(abs(p1.x-p2.x) <= 0.1): return PreviousTan
	#if(p1.x-p2.x > 0.0):
	#	PreviousTan = 1
	#	return 1
	PreviousTan -1
	return -1

var InternalSpeed : float = 0.0
var Vel : float = 0.0#Vector2(0.0, 0.0)

@export var StopAcc : float = 0.0

var ChangingVel : bool = false

@export var PistonCooldownTime : float = .2

#@export var OneWayCollisionMargin : float = -2.0
@export var OneWayCollision : bool = false

func is_in_closed_line() -> bool:
	if(Line is Line2D):
		for i in range(Line.points.size()-1):
			if(is_in_line(position+RigidBody.position, i) ): return true
	return false

func is_in_line(position : Vector2, LineId : int, margin : float = InLineMargin):
	var closest_point := Geometry2D.get_closest_point_to_segment(position, Line.points[LineId], Line.points[LineId+1])
	#print("distance: " + str(closest_point.distance_to(position+RigidBody.position)))
	return closest_point.distance_to(position) <= margin

func _tick_falling() -> void:
	var _falling : bool = !is_in_closed_line()
	if(_falling != Falling):
		Falling = _falling
		if(Falling && RigidBody):
			#print("lol exited")
			RigidBody.freeze = false
		else:
			#print("entered")
			RigidBody.freeze = true
			global_position = RigidBody.global_position
			RigidBody.position = Vector2(0.0,0.0)
			progress = Path.curve.get_closest_offset(Path.to_local(RigidBody.global_position))

func tick_global_speed() -> void:
	Line.GlobalSpeed = Vel

func _tick_one_way_collision() -> void:
	if(Player && CollisionShape):
		#CollisionShape.disabled = Player.global_position.y >= global_position.y-CollisionShape.shape.size.y/2-OneWayCollisionMargin
		if(Player.GravityDirection == Global.GravityDirections.MAIN):
			CollisionShape.disabled = Player.velocity.y < 0
		else:
			CollisionShape.disabled = Player.velocity.y > 0

func _process(delta: float) -> void:
	_reload_material_shader()
	if(OneWayCollision): _tick_one_way_collision()
	if(Type == Types.Piston):
		_piston_movement_tick(delta)
		_piston_speed_tick(delta)
	else:
		if(!Line.Closed): _tick_falling()
		if(!Falling):
			if(Enabled && Line.Enabled && CooldownTimer.is_stopped()):
				_block_movement_tick(delta)
				
				if(ChangingVel && Line.GlobalMovingNode == self && ChangeGlobalSpeed): 
					tick_global_speed()
				if(previous_ratio > progress_ratio && Type != Types.HorizontalChangeDir):
					restart()
				else:
					previous_ratio = progress_ratio
				LastGlobalPosition = global_position
			if(Type != Types.Piston):
				_block_speed_tick(delta)

func _piston_speed_tick(delta: float) -> void:
	if(PistonSwitchDirTimer.is_stopped() && InitialWaitTimer.is_stopped()):
		if(!ChangingVel): progress_ratio += Line.GlobalSpeed * delta
		if(Direction == 1):
			if(InternalSpeed >= Line.Speed): InternalSpeed = Line.Speed
			else: InternalSpeed += Line.Acc*delta
		else:
			if(InternalSpeed >= Line.Speed): InternalSpeed = Line.Speed/3
			else: InternalSpeed += Line.Acc*delta/3
		if(Vel > Line.Speed): Vel = Line.Speed

@export var PistonSwitchDirTimer : Timer 

func _piston_movement_tick(delta : float) -> void:
	progress += InternalSpeed * delta * Direction
	if(PistonSwitchDirTimer.is_stopped() && InitialWaitTimer.is_stopped()):
		#print((progress_ratio <= 0.3 && Direction == 1.0) || (progress_ratio >= 0.7 && Direction == -1.0))
		if( (progress_ratio >= 0.95 && Direction == 1.0) || (progress_ratio <= 0.05 && Direction == -1.0) ):
			if(Direction == -1.0): PistonSwitchDirTimer.start()
			InternalSpeed = 20.0
			Direction *= -1

func _block_speed_tick(delta: float) -> void:
	if(!ChangingVel): progress_ratio += Line.GlobalSpeed * delta
	if(InternalSpeed > Line.Speed): InternalSpeed = Line.Speed
	if(Vel > Line.Speed): Vel = Line.Speed

func _block_movement_tick(delta : float) -> void:
	if(Player && Type == Types.HorizontalChangeDir):
		Direction = (global_position-Player.global_position).normalized().x
		var tan = get_tangent()
		if(tan): Direction *= tan
		#if(global_position > LastGlobalPosition): Direction *= -1.0
	if(Type != Types.None):
		if(Type != Types.HorizontalChangeDir || PlayerInteracted):
			progress += InternalSpeed * delta * Direction
			Vel = (progress_ratio-previous_ratio)/delta #(global_position-LastGlobalPosition)/delta
			if(InternalSpeed < Line.Speed): InternalSpeed += Line.Acc*delta
			else: InternalSpeed = Line.Speed
		elif(Type == Types.HorizontalChangeDir):
			if(!PlayerInteracted && Vel != 0.0):
				progress_ratio += Vel*delta
				Vel = lerp(Vel, 0.0, StopAcc*delta)
				InternalSpeed = abs(Vel)/delta*5
				#print(delta)
				if(abs(Vel) <= .05):
					Vel = Line.InitialAccSpeed
					InternalSpeed = Line.InitialAccSpeed
					if(ChangingVel): tick_global_speed()
					ChangingVel = false
				if(self != Line.GlobalMovingNode && Line.GlobalSpeed <= 0.05):
					InternalSpeed = 0.0
					Vel = 0.0
					ChangingVel = false

var PlayerInteracted : bool = false

func _on_enable_area_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		PlayerInteracted = true
		if(!InitialWaitTimer || InitialWaitTimer.is_stopped()):
			if(InternalSpeed < Line.InitialAccSpeed): InternalSpeed = Line.InitialAccSpeed
			if(!Enabled): restart()
		if(ChangeGlobalSpeed):
			ChangingVel = true
			Line.GlobalMovingNode = self


func _on_enable_area_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		#if(Line.GlobalMovingNode == self): Line.GlobalMovingNode = null
		PlayerInteracted = false
		if(!InitialWaitTimer || InitialWaitTimer.is_stopped()):
			if(InternalSpeed < Line.InitialAccSpeed): InternalSpeed = Line.InitialAccSpeed
		#InternalSpeed = 0.0
		#Vel /= 2


func _on_death_player_area_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		body.On_Death()
