extends Node2D

@onready var Map = $TileMapLayer 

@export var MapSourceId = 0
@export var AtlasCoord : Vector2i = Vector2i(1, 1)
@export var AtlasCoordEraser : Vector2i = Vector2i(-1, -1)
@export var MapGroundLayer = 0

enum Tools{
	GROUND = 0,
	FLAG = 1,
	KEY = 2,
	SAND = 3,
	KILLBOX = 4,
	KILLBOX_BLUE = 5,
	SLIME = 6,
	SPECIAL_SLIME = 7,
	NONE = 8,
	ERASER = 9
}

var flag = preload("res://assets/Levels/flag.tscn")
var key = preload("res://assets/Levels/key.tscn")
var sand = preload("res://assets/Levels/falling_sand.tscn")
var killbox = preload("res://assets/Levels/kill_box.tscn")
var killbox_blue = preload("res://assets/Levels/kill_box_blue.tscn")
var slime = preload("res://assets/Levels/enemie.tscn")
var special_slime = preload("res://assets/Levels/enemie_special.tscn")
var skeleton = preload("res://assets/Levels/enemie_skeleton.tscn")

@onready var SpriteSelected = $SpriteSelected 
@onready var Player = $"Player"
@onready var Camera = $"Camera2D"
@onready var Time_Left = $"Time_Left"

var SelectedTool = Tools.NONE

var _instance = null
var Playing = false

@export var EditorMoveSpeed : float = 200
@export var EditorDragSpeed : float = 1

var Camera_dragging = false
var mouse_start_pos
var screen_start_position

@onready var Bg = $"Bg"

@export var Exported : bool = false

var Is_Hovering : bool = false

var Can_Hover_Placed : bool = false

func check_mouse_pos(x1 : float, y1 : float, x2 : float, y2 : float) -> bool:
	var MousePos = get_global_mouse_position()
	if(MousePos.x >= x1 && MousePos.y >= y1 && MousePos.x <= x2 && MousePos.y <= y2):
		return true
	return false

func set_timeleft(time : float):
	Time_Left.stop()
	Time_Left.wait_time = time
	Time_Left.start()
	Time_Left.paused = true

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Left button was clicked at ", event.position)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			print("Wheel up")
			
			#Change timer
			if(check_mouse_pos(-85.0, -165.0, -29.0, -98.0)):
				set_timeleft(Time_Left.wait_time + 1)
			elif(check_mouse_pos(-25.0, -149.0, -7.0, -106.0)):
				set_timeleft(Time_Left.wait_time + .01)
			else:
				#Change current tool
				#Chatgpt told me this trick lol4
				SelectedTool = (SelectedTool + 1) % Tools.size()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			print("Wheel down")
			if(check_mouse_pos(-85.0, -165.0, -29.0, -98.0)):
				set_timeleft(Time_Left.wait_time - 1)
			elif(check_mouse_pos(-25.0, -149.0, -7.0, -106.0) && Time_Left.wait_time > 1):
				set_timeleft(Time_Left.wait_time - .01)
			else:
				#Chatgpt told me this trick lol4
				SelectedTool -= 1
				if(SelectedTool < 0): SelectedTool = Tools.size()-1
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			mouse_start_pos = event.position
			screen_start_position = Camera.position
			Camera_dragging = true
		else:
			Camera_dragging = false
	elif event is InputEventMouseMotion and Camera_dragging:
		Camera.position = Camera.zoom * (mouse_start_pos - event.position) / 4 + screen_start_position
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Time_Left.paused = true
	if(!Exported):
		Edition.Is_in_editor = true
	else:
		Edition.Is_in_editor = false
		Edition.Is_playing_in_editor = false
		Time_Left.autostart = true
		Time_Left.paused = false
		Time_Left.start()

func set_owner_recursive(node: Node, owner: Node):
	for child in node.get_children():
		child.set_owner(node)
		for child2 in child.get_children():
			if(child2 is Camera2D):
				child2.set_owner(owner)

func save_game():
	play()
	
	print("Saving level...")
	Exported = true
	Bg.Show = true
	
	Time_Left.autostart = true
	Time_Left.paused = false
	Time_Left.start()
	Edition.Is_in_editor = false
	Edition.Is_playing_in_editor = false
	
	var saved_map = self.duplicate()

	set_owner_recursive(saved_map, saved_map)

	# Continue to save
	var save  = PackedScene.new()
	save.pack(saved_map)
	ResourceSaver.save(save, "res://assets/Levels/save/level1.tscn")
	
	#Reset to editor state
	Edition.Is_in_editor = true
	Edition.Is_playing_in_editor = true
	
	Exported = false
	Bg.Show = false
	
	stop()

func play_stop():
	if(Playing): stop()
	else: play()
func play():
	print("Playing...")
	Player.Physics = true
	Playing = true
	Camera.enabled = false
	Player.Camera.enabled = true
	Time_Left.start()
	Time_Left.paused = false
	Edition.Is_playing_in_editor = true
	#Player.OriginalPos = Player.position
func stop():
	print("Stopped...")
	if(!Exported):
		Edition.Is_playing_in_editor = false
		Player.Physics = false
		Playing = false
		Camera.enabled = true
		Time_Left.stop()
		Time_Left.start()
		Time_Left.paused = true
		#region Player
		#Reset Player On Death
		Player.ParticlesDeathFloor.emitting = false
		Player.ParticlesDeathAir.emitting = false
		Player.Sprite.show()
		Player.Dead = false
		#Reset player pos
		Player.Camera.enabled = false
		Player.position = Player.OriginalPos
		Player.strech_size(1, 1)
		Player.LastDirection = 0
		Player.EnabledKillBox = Global.KillBoxTypes.Red
		#endregion
	else:
		Player.On_Death()

func camera_tick(delta):
	if(Input.is_action_pressed("ui_up")):
		Camera.position.y -= EditorMoveSpeed * delta
	elif(Input.is_action_pressed("ui_down")):
		Camera.position.y += EditorMoveSpeed * delta
	if(Input.is_action_pressed("ui_right")):
		Camera.position.x += EditorMoveSpeed * delta
	if(Input.is_action_pressed("ui_left")):
		Camera.position.x -= EditorMoveSpeed * delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(Is_Hovering)
	var MousePos = get_global_mouse_position()
	if(!Exported):
		if(!Playing): camera_tick(delta)
		
		if(Player.Dead): stop()
		
		if(Input.is_action_pressed("editor_eraser")):
			SelectedTool = Tools.ERASER
		
		#Preview of current selected tool
		SpriteSelected.position = MousePos
		SpriteSelected.play(str(SelectedTool))
		if(SelectedTool == Tools.GROUND || SelectedTool == Tools.ERASER || SelectedTool == Tools.SAND || SelectedTool == Tools.KILLBOX || SelectedTool == Tools.KILLBOX_BLUE):
			SpriteSelected.position.x = (floor(SpriteSelected.position.x/16)*16)+16.0
			SpriteSelected.position.y = (floor(SpriteSelected.position.y/16)*16)+10.0
		
		if(Input.is_action_just_pressed("editor_save")):
			save_game()
		if(Input.is_action_just_pressed("editor_play")):
			play_stop()
		#Select with keyboard element
		for i in 10:
			if(Input.is_action_pressed("editor_element"+str(i+1))):
				SelectedTool = i
		if(Is_Hovering && _instance && !_instance.Hovering):
			_instance.queue_free()
			SpriteSelected.play("8")
		if( !Is_Hovering && (Input.is_action_pressed("ui_click") && (SelectedTool == Tools.GROUND || SelectedTool == Tools.ERASER) ) || Input.is_action_just_pressed("ui_click")):
			_instance = null
			match SelectedTool:
				Tools.ERASER:
					_DeleteBlock(MousePos)
				Tools.GROUND:
					_SetBlock(MousePos)
				Tools.FLAG:
					_instance = flag.instantiate()
					_instance.CanHover = false
				Tools.KEY:
					_instance = key.instantiate()
					_instance.AditionalAction = Global.OBJECT_ACTIONS.switch_killbox_type
					_instance.CanHover = false
				Tools.SAND:
					_instance = sand.instantiate()
					_instance.OriginalPos = SpriteSelected.position
					_instance.CanHover = false
				Tools.KILLBOX:
					_instance = killbox.instantiate()
					_instance.CanHover = false
				Tools.KILLBOX_BLUE:
					_instance = killbox_blue.instantiate()
					_instance.CanHover = false
				Tools.SLIME:
					_instance = slime.instantiate()
					_instance.Enabled = false
					_instance.OriginalPos = SpriteSelected.position
					_instance.CanHover = false
				Tools.SPECIAL_SLIME:
					_instance = special_slime.instantiate()
					_instance.Enabled = false
					_instance.OriginalPos = SpriteSelected.position
					_instance.CanHover = false
			if(_instance):
				add_child(_instance)
				_instance.position = SpriteSelected.position
		#Hover hover elements
		if(Input.is_mouse_button_pressed(1)):
			if(_instance):
				_instance.position = SpriteSelected.position
		else:
			if(_instance):# && _instance.get("CanHover")):
				_instance.CanHover = true
			_instance = null

func _SetBlock(Pos):
	var LocalPos = Map.local_to_map(Pos)
	Map.set_cell(LocalPos, MapSourceId, AtlasCoord)

func _DeleteBlock(Pos):
	var LocalPos = Map.local_to_map(Pos)
	Map.set_cell(LocalPos, MapSourceId, AtlasCoordEraser)

func _on_time_left_timeout() -> void:
	stop()
