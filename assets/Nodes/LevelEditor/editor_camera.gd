extends Camera2D

@export var EditorCameraSpeed : float = 300.0
@export var EditorCameraSpeedSlow : float = 100.0

@export var EditorCameraMouseSpeed : float = 400.0
@export var EditorCameraZoomVel : Vector2 = Vector2(0.7, 0.7)

var PrevMousePosition : Vector2 = Vector2(0.0, 0.0)
var PrevCameraPosition : Vector2 = Vector2(0.0, 0.0)

var EnabledMovement = true


func set_enabled_camera(state : bool) -> void:
	enabled = state
	EnabledMovement = state

func _ready() -> void:
	pass

func _editor_camera_tick(delta: float) -> void:
	if(!EnabledMovement): return
	#Keyboard/Control movement
	var _speed = EditorCameraSpeed if !Input.is_action_pressed("ui_editor_move_slow") else EditorCameraSpeedSlow
	if(Input.is_action_pressed("ui_editor_left")):
		position.x -= _speed *delta 
	elif(Input.is_action_pressed("ui_editor_right")):
		position.x += _speed *delta
	if(Input.is_action_pressed("ui_editor_down")):
		position.y += _speed *delta
	elif(Input.is_action_pressed("ui_editor_up")):
		position.y -= _speed *delta
	#Mouse movement
	if(Input.is_action_just_pressed("ui_editor_move_mouse")):
		PrevMousePosition = get_global_mouse_position()
		PrevCameraPosition = position
	elif(Input.is_action_pressed("ui_editor_move_mouse")):
		position = PrevCameraPosition - (get_global_mouse_position() - PrevMousePosition) * EditorCameraZoomVel
	#Zoom in & Out
	if(Input.is_action_pressed("ui_editor_zoom_out")):
		#print("zoom out")
		zoom += EditorCameraZoomVel * delta
	elif(Input.is_action_pressed("ui_editor_zoom_in")):
		zoom -= EditorCameraZoomVel * delta
	
func _process(delta: float) -> void:
	_editor_camera_tick(delta)
