@tool
extends Area2D

@export var Visible : bool = true
@onready var Sprite = $Sprite

@onready var Player = $"../Player"
@export var CanChange = true
@export var Enabled : bool = true

@export var Laser_Colors : Array[Array] = [ [Vector4(229.0, 0.0, 0.0, 1.0), Vector4(5.0, 0.0, 0.0, 1.0)] ]

var TweenMove = null

@export var Laser_Color : Global.LASER_COLORS = Global.LASER_COLORS.RED

const TileMoveSpeed : float = 20.0

func editor_reset() -> void:
	_set_visible(true)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Sprite.region_rect.position.y = 0.0
	if(!Visible): self.hide()
	
	#var shader = load("res://assets/Levels/Shader/kill_box.gdshader")
	
	#var shader_material = ShaderMaterial.new()
	#shader_material.shader = shader
	#Sprite.material = shader_material
	
	#Sprite.material.set_shader_parameter("tile_size", scale)
	
var editable = preload("res://assets/Scripts/default_object.gd").new()
var Hovering : bool = false
@export var CanHover : bool = false

func _set_visible(visible : bool):
	if(visible): 
		#Sprite.play("default")
		$CollisionShape2D.show()
		Sprite.show()
	else:
		#Sprite.play("disabled")
		$CollisionShape2D.hide()
		Sprite.hide()
	$CollisionShape2D.disabled = !visible


func _process(delta: float) -> void:
	Sprite.material.set_shader_parameter("color4", Laser_Colors[Laser_Color][0])
	Sprite.material.set_shader_parameter("color7", Laser_Colors[Laser_Color][1])
	#print(Laser_Colors)
	if(!Engine.is_editor_hint()): Sprite.region_rect.position.y += TileMoveSpeed * delta
	#print(Sprite.region_rect.position.y)
		
func _on_body_entered(body: Node2D) -> void:
	if(Edition.Is_in_editor && !Edition.Is_playing_in_editor): return
	if(Engine.is_editor_hint()): return
	if ((body.is_in_group("Player") || body.is_in_group("Enemie")) && visible && Enabled):
		print("hide")
		SaveGame.get_player().LASERS_ENABLED[Laser_Color] = true
		_set_visible(false)
		LevelManager.AddStyle(0, "Laser")
		
