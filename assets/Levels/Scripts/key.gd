extends Area2D

@onready var Player = $"../Player"
@export var AditionalAction : Global.OBJECT_ACTIONS = Global.OBJECT_ACTIONS.none

@onready var Sprite = $"AnimatedSprite2D"
@onready var Light = $"PointLight2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("default")

var editable = preload("res://assets/Levels/Scripts/default_object.gd").new()
var Hovering : bool = false
@export var CanHover : bool = false

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
		position = get_global_mouse_position()
		self.position.x = (floor(self.position.x/grab_grid)*grab_grid)+16.0
		self.position.y = (floor(self.position.y/grab_grid)*grab_grid)+10.0
	if(Edition.Is_in_editor && !Edition.Is_playing_in_editor):
		set_key_state(false)

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") && Player):
		set_key_state(true)

func set_key_state(state : bool):
	Sprite.visible = !state
	Light.enabled = !state
	Player.HaveKey = state
	if(state):
		Player._play_sound(Player.AudioSwitch, false)
		if(AditionalAction == Global.OBJECT_ACTIONS.switch_killbox_type):
			if(Player.EnabledKillBox == Global.KillBoxTypes.Red):
				Player.EnabledKillBox = Global.KillBoxTypes.Blue
			else:
				Player.EnabledKillBox = Global.KillBoxTypes.Red
		elif(AditionalAction == Global.OBJECT_ACTIONS.MoveLava):
			Player.MoveLava = true
		else:
			Player._play_sound(Player.AudioKey, false)
