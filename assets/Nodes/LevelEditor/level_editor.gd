extends Node2D

var AdvancedMode

var IsTileMapSelected : bool = false
@export var Cursor : Node2D
@export var SelectableObjects : Array[Array]
@export var SelectableAutotiles : Array[int]
@export var AutotileTilemapLayers : Array[int]
@export var TilesetLayers : Array[TileMapLayer]
@export var EditorCamera : Camera2D
@export var Time_Left : Timer
@export var Player : Node2D
@export var PlayerCamera : Camera2D
@export var LevelData : Node2D
var Paused : bool = false

func _ready() -> void:
	Edition.Is_in_editor = true
	Time_Left.paused = true
	
func _process(delta: float) -> void:
	_play_state_tick()

func _play_state_tick(ResetAll : bool = false) -> void:
	if(Input.is_action_just_pressed("ui_editor_play") || Input.is_action_just_pressed("ui_editor_pause") ):
		print("Is playing in editor: " + str(Edition.Is_playing_in_editor))
		if(!Edition.Is_playing_in_editor && Input.is_action_just_pressed("ui_editor_pause")):
			return
		if(!Paused && !Edition.Is_playing_in_editor && Input.is_action_just_pressed("ui_editor_play")):
			_cache_editor_elements_values()
		Edition.Is_playing_in_editor = !Edition.Is_playing_in_editor
		Edition.Is_in_editor = true
		Player.Physics = Edition.Is_playing_in_editor
		Player.EnemiesPhysics = Edition.Is_playing_in_editor
		
		EditorCamera.set_enabled_camera(!Edition.Is_playing_in_editor)
		PlayerCamera.enabled = Edition.Is_playing_in_editor
		
		if(Input.is_action_just_pressed("ui_editor_pause")):
			Paused = true
			Time_Left.paused = true
		else:
			if(Edition.Is_playing_in_editor): Time_Left.paused = false
			else:
				Time_Left.start()
				Time_Left.paused = true
			Paused = false
		#Si es que quiere detener de jugar se resetea el estado del jugador
		if((Input.is_action_just_pressed("ui_editor_play") && !Edition.Is_playing_in_editor) || ResetAll) :
			_reset_play()

func _cache_editor_elements_values() -> void:
	if(Player): Player.cache_values_editor()
	for child in get_children():
		if(child.is_in_group("Enemie") || child.is_in_group("sand")):
			child.cache_values_editor()

func _reset_play() -> void:
	for i in range(SaveGame.get_player().LASERS_ENABLED.size()):
		SaveGame.get_player().LASERS_ENABLED[i] = false
	if(Player):
		EditorCamera.position = Player.position
		Player.editor_reset()
	for child in get_children():
		if(child.is_in_group("Enemie") || child.is_in_group("sand") || child.is_in_group("Laser")):
			child.editor_reset()

func _on_buttonplus_time_pressed() -> void:
	Time_Left.wait_time += 1.0
	Time_Left.start()
	Time_Left.paused = true

func _on_button_minus_time_pressed() -> void:
	Time_Left.wait_time -= 1.0
	Time_Left.start()
	Time_Left.paused = true


func _on_advanced_mode_button_pressed() -> void:
	AdvancedMode = !AdvancedMode

var ButtonHovered : bool = false

func _button_hovered() -> void:
	ButtonHovered = true

func _button_not_hovered() -> void:
	ButtonHovered = false
