extends RigidBody2D

@export var can_be_pushed : bool = false
@export var push_force : float = 80.0
@export var wait_time : float = 0.1

@export var GravityDirection : Global.GravityDirections = Global.GravityDirections.MAIN
@onready var CurrentGravityDirection : Global.GravityDirections = GravityDirection

@export var is_falling : bool = false
var was_falling : bool = is_falling

var is_playing : bool = false

@onready var SandTimer = $SandTimer

var OriginalPos = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(!is_falling):
		set_deferred("freeze", true)
	else:
		set_deferred("freeze", false)
	SandTimer.wait_time = wait_time

var editable = preload("res://assets/Levels/Scripts/default_object.gd").new()
var Hovering : bool = false
var StatePlaying : bool = false
@export var CanHover : bool = false
@onready var Player = SaveGame.get_player()

func _input(event):
	if(Edition.Is_in_editor && CanHover):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if(event.pressed && editable.Editor_Hover_Check(self.position.x, self.position.y, get_global_mouse_position())):
					$"../".Is_Hovering = true
					Hovering = true
				else:
					$"../".Is_Hovering = false
					Hovering = false

@export var grab_grid : float = 8.0
func _process(delta: float) -> void:
	CurrentGravityDirection = GravityDirection * Player.GlobalGravityDirection
	if(CurrentGravityDirection == Global.GravityDirections.INVERTED):
		set_falling(true)
	gravity_scale = CurrentGravityDirection
	
	if(Edition.Is_in_editor && Edition.Is_playing_in_editor != is_playing):
		self.position = OriginalPos
	elif(Edition.Is_in_editor && !Edition.Is_playing_in_editor):
		OriginalPos = self.position
	is_playing = Edition.Is_playing_in_editor
	if(Edition.Is_in_editor && CanHover && Hovering):
		if(Edition.IsErasingInEditor):
			self.queue_free()
		position = get_global_mouse_position()
		self.position.x = (floor(self.position.x/grab_grid)*grab_grid)+16.0
		self.position.y = (floor(self.position.y/grab_grid)*grab_grid)+10.0
	#if(is_falling && Edition.Is_in_editor && !Edition.Is_playing_in_editor):
	#	set_falling(false)
	#	self.position = OriginalPos
	if(!Edition.Is_in_editor && $"../Player"):
		if($"../Player".Paused):
			was_falling = is_falling
			set_deferred("freeze", false)
			self.set_deferred("sleeping", false)
			is_falling = false
		#else:
			#if(was_falling && !is_falling):
			#	set_falling(true)
		#set_falling(false)
@export var MAX_SPEED : float = 300.0

func _integrate_forces(state):
	var velocity = state.linear_velocity
	var speed = velocity.length()
	
	if (speed > MAX_SPEED):
		state.linear_velocity = velocity.normalized() * MAX_SPEED

#var SlamAdd : int = 1000

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") || body.is_in_group("Enemie")):
		if (body.is_in_group("Player")):
			#Player.GravitySandFallDirection = Player.GlobalGravityDirection
			#if(body.GroundSmash):
			#	MAX_SPEED *= SlamAdd
			#GravityDirection = Player.GravityDirection
			body.OnSand = true
			if(!body.GroundSmash):
				await get_tree().create_timer(wait_time).timeout
		set_falling(true)

func set_falling(falling : bool) -> void:
	print("Changing to " + str(falling))
	set_deferred("freeze", !falling)
	self.set_deferred("sleeping", !falling)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		#Player.GravitySandFallDirection = Global.GravityDirections.MAIN
		body.OnSand = false


func _on_area_2d_crush_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") && CurrentGravityDirection != Global.GravityDirections.INVERTED):
		body.On_Death()
