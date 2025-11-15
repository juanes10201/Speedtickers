extends Area2D

@onready var Player : ClassPlayer = $"../Player"
@export var AditionalAction : Global.OBJECT_ACTIONS = Global.OBJECT_ACTIONS.none
@export var AnotherAction : Global.OBJECT_ACTIONS = Global.OBJECT_ACTIONS.none

@onready var Sprite : AnimatedSprite2D = $"AnimatedSprite2D"
@onready var Light : PointLight2D = $"PointLight2D"

@onready var TimerRespawn : Timer = $"TimerRespawn"

@export var Respawn : bool = false
@export var RespawnTime : float = 1.0

@export var TakeKey : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(AditionalAction == Global.OBJECT_ACTIONS.Switch_Player_Gravity):
		$AnimatedSprite2D.play("orb")
	else:
		$AnimatedSprite2D.play("default")
	if(TimerRespawn):
		TimerRespawn.wait_time = RespawnTime

var editable = preload("res://assets/Levels/Scripts/default_object.gd").new()
var Hovering : bool = false
@export var CanHover : bool = false
var done = false

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
	if(Edition.Is_in_editor && CanHover && Hovering):
		if(Edition.IsErasingInEditor):
			self.queue_free()
		position = get_global_mouse_position()
		self.position.x = (floor(self.position.x/grab_grid)*grab_grid)+16.0
		self.position.y = (floor(self.position.y/grab_grid)*grab_grid)+10.0
	if(Edition.Is_in_editor && !Edition.Is_playing_in_editor):
		set_key_state(false, false)
	elif(Respawn):
		if(done):
			Sprite.self_modulate.a = lerpf(Sprite.self_modulate.a, 0.6, 15*delta)
		else:
			Sprite.self_modulate.a = lerpf(Sprite.self_modulate.a, 1, 5*delta)
			if($AnimatedSprite2D.animation == "get_orb"):
				$AnimatedSprite2D.play("respawn_orb")
			elif(!$AnimatedSprite2D.is_playing()):
				$AnimatedSprite2D.play("orb")

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") && Player && !done):
		set_key_state(true, true)
		if(AditionalAction == Global.OBJECT_ACTIONS.Switch_Player_Gravity):
			LevelManager.AddStyle(0, "Changed Gravity")
		else: LevelManager.AddStyle(0, "Got Key")

func set_key_state(state : bool, PlayAction : bool):
	if(!Respawn):
		Sprite.visible = !state
	elif(state):
		Sprite.self_modulate.a = 0.3
	if(Light): Light.enabled = !state
	if(TakeKey):
		Player.HaveKey = state
	if(PlayAction):
		done = true
		if(AditionalAction != Global.OBJECT_ACTIONS.Switch_Player_Gravity):
			Player._play_sound(Player.AudioSwitch, false)
		if(AditionalAction == Global.OBJECT_ACTIONS.none):
			Player._play_sound(Player.AudioKey, false)
		if(AditionalAction == Global.OBJECT_ACTIONS.Switch_Player_Gravity):
			$AnimatedSprite2D.play("get_orb")
		if(Respawn):
			TimerRespawn.start() 
		Global.Play_Global_Action(AditionalAction)
		Global.Play_Global_Action(AnotherAction)


func _on_timer_respawn_timeout() -> void:
	done = false
	set_key_state(false, false)
