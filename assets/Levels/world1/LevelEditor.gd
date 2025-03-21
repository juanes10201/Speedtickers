extends Node2D

@onready var Map = $TileMapLayer 

@export var MapSourceId = 0
@export var AtlasCoord : Vector2i = Vector2i(1, 1)
@export var MapGroundLayer = 0

enum Tools{
	GROUND = 0,
	FLAG = 1,
	KEY = 2,
	SAND = 3,
	KILLBOX = 4,
	KILLBOX_BLUE = 5,
	SLIME = 6,
	SPECIAL_SLIME = 7
}

var flag = preload("res://assets/Levels/flag.tscn")
var key = preload("res://assets/Levels/key.tscn")
var sand = preload("res://assets/Levels/falling_sand.tscn")
var killbox = preload("res://assets/Levels/kill_box.tscn")
var killbox_blue = preload("res://assets/Levels/kill_box_blue.tscn")
var slime = preload("res://assets/Levels/enemie.tscn")
var special_slime = preload("res://assets/Levels/enemie_special.tscn")
var skeleton = preload("res://assets/Levels/enemie_skeleton.tscn")

var SelectedTool = Tools.GROUND

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Left button was clicked at ", event.position)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			print("Wheel up")
			#Chatgpt told me this trick lol4
			SelectedTool = (SelectedTool + 1) % Tools.size()
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Select with keyboard element
	for i in 10:
		if(Input.is_action_pressed("editor_element"+str(i+1))):
			SelectedTool = i
	if(Input.is_action_just_pressed("ui_click")):
		var MousePos = get_global_mouse_position()
		var _instance = null
		match SelectedTool:
			Tools.GROUND:
				_SetBlock(MousePos)
			Tools.FLAG:
				_instance = flag.instantiate()
			Tools.KEY:
				_instance = key.instantiate()
			Tools.SAND:
				_instance = sand.instantiate()
			Tools.KILLBOX:
				_instance = killbox.instantiate()
			Tools.KILLBOX_BLUE:
				_instance = killbox_blue.instantiate()
			Tools.SLIME:
				_instance = slime.instantiate()
			Tools.SPECIAL_SLIME:
				_instance = special_slime.instantiate()
		if(_instance):
			add_child(_instance)
			_instance.position = MousePos

func _SetBlock(Pos):
	var LocalPos = Map.local_to_map(Pos)
	print(LocalPos)
	Map.set_cell(LocalPos, MapSourceId, AtlasCoord)
