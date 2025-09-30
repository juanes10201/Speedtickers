extends RigidBody2D

@export var MAX_SPEED : float = 300.0

@onready var Sprite = $AnimatedSprite2D
@onready var WaitTimer : Timer = $Time_Hit
@onready var Timer_Start : Timer = $Timer_Start
@export var Time_Start : float = 1.0
@export var WaitTime : float = 1
@onready var Timer_BackDelay : Timer = $Timer_BackDelay
@export var Time_BackDelay : float = .5

@export var AutoStartHit : bool = true
@export var StartSpeed : float = 100.0
@export var GravityDirection : Global.GravityDirections = Global.GravityDirections.MAIN
@onready var CurrentDirecion : Global.GravityDirections = GravityDirection
@onready var Direction = GravityDirection

enum MoveTypes{
	Horizontal,
	Vertical
}
var VelX : float = 0

@export var MoveType : MoveTypes = MoveTypes.Vertical

@onready var OriginalPos = position.y if MoveType == MoveTypes.Horizontal else position.x

func _ready() -> void:
	WaitTimer.wait_time = WaitTime
	Timer_BackDelay.wait_time = Time_BackDelay
	Timer_Start.wait_time = Time_Start
	if(AutoStartHit):
		Timer_Start.start()

func _physics_process(delta: float) -> void:
	Direction = GravityDirection * CurrentDirecion
	gravity_scale = Direction*GravityDirection
	if(MoveType == MoveTypes.Horizontal):
		position.y = OriginalPos
		gravity_scale = 0
		VelX = lerp(VelX, MAX_SPEED*Direction*GravityDirection, 1*delta)
	else:
		position.x = OriginalPos
	
	if(!WaitTimer.is_stopped()):
		Sprite.material.set_shader_parameter("progress", 1-(WaitTimer.time_left/WaitTimer.wait_time))
	if(!Timer_Start.is_stopped()):
		Sprite.material.set_shader_parameter("progress", 1-(Timer_Start.time_left/Timer_Start.wait_time))

func _integrate_forces(state):
	if(MoveType == MoveTypes.Vertical):
		var velocity = state.linear_velocity
		var speed = velocity.length()

		if(!Timer_Start.is_stopped()):
			state.linear_velocity.y = 0

		if(velocity.y != 0 && velocity.y < 100 && velocity.y>CurrentDirecion):
			state.linear_velocity.y = velocity.normalized().y * StartSpeed

		if(speed > MAX_SPEED):
			state.linear_velocity.y = velocity.normalized().y * MAX_SPEED
	elif(MoveType == MoveTypes.Horizontal):
		var velocity = state.linear_velocity
		var speed = velocity.length()
		state.linear_velocity.x = VelX

		if(!Timer_Start.is_stopped() && !Timer_BackDelay.is_stopped() && !WaitTimer.is_stopped()):
			state.linear_velocity.x = 0

		if(velocity.x < 100 && velocity.x>CurrentDirecion):
			state.linear_velocity.x = StartSpeed*Direction*GravityDirection
			VelX = StartSpeed*Direction*GravityDirection
		print(VelX)

		if(speed > MAX_SPEED):
			state.linear_velocity.x = velocity.normalized().x * MAX_SPEED

func set_falling(falling : bool) -> void:
	print("Changing piston fall to " + str(falling))
	set_deferred("freeze", !falling)
	self.set_deferred("sleeping", !falling)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Player")):
		SaveGame.get_player().On_Death()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		SaveGame.get_player().On_Death()


func _on_time_hit_timeout() -> void:
	CurrentDirecion = GravityDirection
	set_falling(true)
	VelX = 0
	print(CurrentDirecion)

func _on_tileset_area_body_entered(body: Node2D) -> void:
	if(body is TileMapLayer || body .is_in_group("Piston")):
		if(Timer_Start.is_stopped()):
			if(CurrentDirecion == GravityDirection):
				Timer_BackDelay.start()
			else:
				WaitTimer.start()
			set_falling(false)


func _on_timer_back_delay_timeout() -> void:
	CurrentDirecion *= -1
	set_falling(true)
	VelX = 0
	print(CurrentDirecion)


func _on_timer_start_timeout() -> void:
	CurrentDirecion = GravityDirection
	set_falling(true)
	VelX = 0
	print(CurrentDirecion)
