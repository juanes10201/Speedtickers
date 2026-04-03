extends TouchScreenButton

@export var PressedAction : String = "player_jump"

func _on_pressed() -> void:
	print("Button Pressed")
	var event = InputEventAction.new()
	event.action = PressedAction
	event.pressed = true  # true to press, false to release
	Input.parse_input_event(event)


func _on_released() -> void:
	print("Button Up")
	var event = InputEventAction.new()
	event.action = PressedAction
	event.pressed = false
	Input.parse_input_event(event)
