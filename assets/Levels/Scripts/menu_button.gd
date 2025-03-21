extends Button

@export var BUTTON_ACTION = Global.BUTTON_ACTIONS.none
@export var ADITIONAL_ARGUMENT : String = ""

@export var HoverDif = 30
@export var PressedDif = -20

@onready var original_size = self.size
@onready var ControlNode = $"../../pause_menu"
@onready var SelectedSprite = $SelectedSprite
@onready var Player = $"../../../../Player"
@export var IsPixelartButton : bool = false

@onready var tex_selected : Texture = preload("res://assets/Sprites/levelnote-selected.png") if IsPixelartButton else null
@onready var tex_unselected : Texture = self.icon

@onready var hover_size : Vector2 = Vector2(original_size.x+HoverDif, original_size.y+HoverDif)
@onready var press_size : Vector2 = Vector2(original_size.x+PressedDif, original_size.y+PressedDif)

@export var ShowOnExpo : bool = true

var touching_mouse : bool = false

var PressedAnim : bool = false

var tween_hover = null
var tween_press = null
var tween_normal = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if(text == "1"):
	#	grab_focus()
	if(!ShowOnExpo && Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo_shangai):
		queue_free()
	_set_text_size(original_size.y)
	if(BUTTON_ACTION == Global.BUTTON_ACTIONS.move_to_level_starting_with):
		ADITIONAL_ARGUMENT += str(text)
		BUTTON_ACTION = Global.BUTTON_ACTIONS.move_to_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#region Button anims
	if(!PressedAnim):
		var Mouse_pos = get_global_mouse_position()
		#Checks if mouse is touching button or if has focused(For controller support)
		if(has_focus() || (Mouse_pos.x >= self.position.x && Mouse_pos.x <= self.position.x + self.size.x && Mouse_pos.y >= self.position.y && Mouse_pos.y <= self.position.y + self.size.y+20)):
			if(IsPixelartButton && !touching_mouse):
				$"../Iconuser"._update_best_scores(float(text))
			touching_mouse = true
			if(IsPixelartButton): icon = tex_selected
			#region On pressed
			if(Input.is_action_pressed("ui_click") && self.size.x < original_size.x+PressedDif):
				var tween_button = get_tree().create_tween()
				tween_button.tween_property(self, "size", press_size, .2)
				tween_button.play()
				#_set_size_button(lerpf(self.size.x, original_size.x+PressedDif, 5*delta),  lerpf(self.size.y, original_size.y+PressedDif, 5*delta))
			#region Hover
			elif(!tween_press):
				var tween_button = get_tree().create_tween()
				tween_button.tween_property(self, "size", hover_size, 1)\
				.set_ease(Tween.EASE_OUT)\
				.set_trans(Tween.TRANS_ELASTIC)
				tween_button.play()
				#_set_size_button(lerpf(self.size.x, original_size.x+HoverDif, 5*delta), lerpf(self.size.y, original_size.y+HoverDif, 5*delta))
			#endregion
		#region Return to normal state
		elif(self.size != original_size):
			if(touching_mouse):
				if(IsPixelartButton): icon = tex_unselected
			touching_mouse = false
			var tween_button = get_tree().create_tween()
			tween_button.tween_property(self, "size", original_size, 1)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_ELASTIC)
			tween_button.play()
			#_set_size_button(lerpf(self.size.x, original_size.x, 10*delta), lerpf(self.size.y, original_size.y, 10*delta))
		#endregion
	#endregion
	_set_text_size(self.size.x)

func _set_text_size(X : float):
	var tosize = X-45
	if(get_theme_font_size("font_size") != tosize):
		add_theme_font_size_override('font_size', X-52)

func _on_pressed() -> void:
	print("Button pressed!")
	if(BUTTON_ACTION == Global.BUTTON_ACTIONS.resume_game && Player):
		Player._pause_game()
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.restart_level):
		Player.TransitionOut.show()
		Player.TransitionOut.fade_out()
		await(get_tree().create_timer(Player.TimeDeath).timeout)
		if get_tree(): get_tree().reload_current_scene()
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.config_menu):
		print("TO-DO: Lazy developer didn't implement config menu...")
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.move_to_scene):
		var _scene_string : String = "res://assets/Levels/world1/" + ADITIONAL_ARGUMENT + ".tscn"
		get_tree().change_scene_to_file(_scene_string)
		
