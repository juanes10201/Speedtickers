extends Area2D

@export var Visible : bool = true
@onready var Sprite = $AnimatedSprite2D

@onready var Player = $"../Player"
@export var Type = Global.KillBoxTypes.Red
@export var CanChange = true

var TweenMove = null

@export var Laser_Color : Global.LASER_COLORS = Global.LASER_COLORS.RED

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

func _set_visible(visible : bool):
	if(visible): 
		Sprite.play("default")
		$CollisionShape2D.show()
	else:
		Sprite.play("disabled")
		$CollisionShape2D.hide()
	$CollisionShape2D.disabled = visible

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
		
func _on_body_entered(body: Node2D) -> void:
	if ((body.is_in_group("Player") || body.is_in_group("Enemie")) && visible):
		SaveGame.get_player().LASERS_ENABLED[Laser_Color] = true
		_set_visible(false)
		LevelManager.AddStyle(0, "Laser")
		
