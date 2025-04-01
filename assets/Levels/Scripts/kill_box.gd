extends Area2D

@export var Visible : bool = true
@onready var Sprite = $AnimatedSprite2D

@onready var Player = $"../Player"
@export var Type = Global.KillBoxTypes.Red
@export var CanChange = true

var TweenMove = null

enum Actions{
	none,
	raise_up_on_key
}
@export var AditionalAction = Actions.none

@export var lavaMovDif : float = 10
var posygoto : float = position.y - lavaMovDif
@onready var LavaTimer = $LavaTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(!Visible): self.hide()
	
	var shader = load("res://assets/Levels/Shader/kill_box.gdshader")
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	Sprite.material = shader_material
	
	Sprite.material.set_shader_parameter("tile_size", scale)
	
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
	#If current killbox
	if(Player && Player.EnabledKillBox == Type && CanChange):
		Sprite.play("default")
		$CollisionShape2D.hide()
		$CollisionShape2D.disabled = false
	elif(CanChange):
		#if(AditionalAction.raise_up_on_key):
		Sprite.play("disabled")
		$CollisionShape2D.disabled = true
	if(AditionalAction == Actions.raise_up_on_key && Player.MoveLava):
		position.y = lerpf(position.y, posygoto, 2 * delta)
		position.y -= lavaMovDif/10
		if(LavaTimer.is_stopped()):
			posygoto = position.y - lavaMovDif
			LavaTimer.start()
		
func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player") || body.is_in_group("Enemie")):
		body.On_Death()
		
