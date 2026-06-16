extends PathFollow2D

@onready var Line : Line2D = get_parent().get_parent()
@export var Enabled : bool = true
@export var CooldownAnim : bool = true

@export var CooldownTimer : Timer
@onready var OriginalRatio : float = progress_ratio

@onready var previous_ratio : float = progress_ratio

enum Types {
	None,
	Horizontal,
	HorizontalChangeDir
}
@export var Type : Types = Types.Horizontal
@onready var Player = SaveGame.get_player()

var Direction : float = 1.0
@export var RigidBody : RigidBody2D
@onready var SizeX : float = RigidBody.get_node("Collision").shape.size.x if $"RigidBody/Collision" else 16.0

@onready var LastGlobalPosition : Vector2 = global_position
@export var ChangeGlobalSpeed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(Enabled):
		restart()

func restart() -> void:
	if(Type == Types.None): return
	if(!Enabled || progress_ratio >= OriginalRatio):
		Enabled = true
		if(Type == Types.HorizontalChangeDir): return
		#if(CooldownTimer): CooldownTimer.start()
		#progress_ratio = OriginalRatio
		#previous_ratio = progress_ratio

func _reload_material_shader() -> void:
	for Child in get_children():
		if(Child is RigidBody2D):
			if(!CooldownTimer.is_stopped()):
				Child.material.set_shader_parameter("progress", 1-(CooldownTimer.time_left/CooldownTimer.wait_time) )
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

func tick_global_speed() -> void:
	Line.GlobalSpeed = Vel

func _process(delta: float) -> void:
	_reload_material_shader()
	if(Enabled && Line.Enabled && CooldownTimer.is_stopped()):
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
		if(ChangingVel && Line.GlobalMovingNode == self && ChangeGlobalSpeed): 
			tick_global_speed()
		if(previous_ratio > progress_ratio && Type != Types.HorizontalChangeDir):
			restart()
		else:
			previous_ratio = progress_ratio
		LastGlobalPosition = global_position
	if(!ChangingVel): progress_ratio += Line.GlobalSpeed * delta
	if(InternalSpeed > Line.Speed): InternalSpeed = Line.Speed
	if(Vel > Line.Speed): Vel = Line.Speed
	#print(Vel)
	#print(InternalSpeed)

var PlayerInteracted : bool = false

func _on_enable_area_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		PlayerInteracted = true
		if(InternalSpeed < Line.InitialAccSpeed): InternalSpeed = Line.InitialAccSpeed
		if(ChangeGlobalSpeed):
			ChangingVel = true
			Line.GlobalMovingNode = self
		if(!Enabled):
			restart()


func _on_enable_area_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		#if(Line.GlobalMovingNode == self): Line.GlobalMovingNode = null
		PlayerInteracted = false
		if(InternalSpeed < Line.InitialAccSpeed): InternalSpeed = Line.InitialAccSpeed
		#InternalSpeed = 0.0
		#Vel /= 2
