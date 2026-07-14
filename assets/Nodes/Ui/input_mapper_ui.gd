extends Node2D
@export var InputMapName : String = "player_dash" 
@export var NodeKeyboardKeys : Node

var MappingInput : bool = false
var MappingInputId : int = 0

func _ready() -> void:
	_reload_keys()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(MappingInput):
		pass

func _reload_keys() -> void:
	var key_count = 0
	for Child in NodeKeyboardKeys.get_children():
		Child.Count = key_count
		Child.set_text(get_input_event_key(key_count, InputMapName))
		key_count += 1

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed && !event.echo && MappingInput:
		var keycode = event.keycode  #event.physical_keycode
		var pressed_key : String = OS.get_keycode_string(keycode)
		print("Key pressed: ", pressed_key)
		remap_input(event, pressed_key, InputMapName, MappingInputId)
		MappingInput = false

func remap_input(event : InputEvent, pressed_key : String, InputName : String, InputId : int) -> void:
	var events = InputMap.action_get_events(InputName)
	InputMap.action_add_event(InputName, event)
	_reload_keys()
	#print(events[InputId]["InputEventKey"])

func get_input_event_key(InputId : int, InputName : String) -> String:
	var events = InputMap.action_get_events(InputName)
	var event = events[InputId]
	if event is InputEventKey:
		return OS.get_keycode_string(event.physical_keycode)
	return ""

func button_was_pressed(id : int) -> void:
	print("Remapping input: " + InputMapName + "; Button id: " + str(id))
	MappingInput = true
	MappingInputId = id

func _on_interact_button_pressed() -> void:
	pass
		
