extends Button

@export var BUTTON_ACTION = Global.BUTTON_ACTIONS.none
@export var ADITIONAL_ARGUMENT : String = ""

@export var HoverDif : float = 30
@export var PressedDif : float = -20

@onready var original_size : Vector2 = self.size
@onready var ControlNode = $"../../pause_menu"
@onready var SelectedSprite = $SelectedSprite
@onready var Player : ClassPlayer = SaveGame.get_player()
@export var IsPixelartButton : bool = false

@export var FadeTransition : bool = false

@onready var tex_selected : Texture = preload("res://assets/Sprites/levelnote-selected.png") if IsPixelartButton else null
@onready var tex_unselected : Texture = self.icon

@onready var hover_size : Vector2 = Vector2(original_size.x+HoverDif, original_size.y+HoverDif)
@onready var press_size : Vector2 = Vector2(original_size.x+PressedDif, original_size.y+PressedDif)

@export var ShowOnExpo : bool = true

@export var BSide : bool = false

enum BoxSize{
	Mini,
	Regular
}

@export var MobileBoxSize : BoxSize = BoxSize.Regular

var touching_mouse : bool = false

var PressedAnim : bool = false

var tween_hover = null
var tween_press = null
var tween_normal = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if(text == "1"):
	#	grab_focus()
	
	if(Edition.Mobile):
		var TouchButton
		if(MobileBoxSize == BoxSize.Mini): TouchButton = load("res://assets/Levels/TouchScreenButtonMini.tscn")
		elif(MobileBoxSize == BoxSize.Regular): TouchButton = load("res://assets/Levels/TouchScreenButtonBig.tscn")
		if(TouchButton):
			add_child(TouchButton.instantiate())
		
	if(!ShowOnExpo && Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo_shangai):
		queue_free()
	_set_text_size(original_size.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!Edition.Mobile):
		#region Press Controller
		if(Input.is_action_just_pressed("ui_click_controller") &&  has_focus()):
			_on_pressed()
		#endregion
		#region Button anims
		if(!PressedAnim):
			var Mouse_pos = get_global_mouse_position()
			#Checks if mouse is touching button or if has focused(For controller support)
			if(has_focus() || (Mouse_pos.x >= self.position.x && Mouse_pos.x <= self.position.x + self.size.x && Mouse_pos.y >= self.position.y && Mouse_pos.y <= self.position.y + self.size.y+20)):
				if(IsPixelartButton && !touching_mouse):
					if($"../../Bg"): $"../../Bg".frame = int(text)-1
					if($"../Iconuser"): $"../Iconuser"._update_best_scores(float(text))
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
	var tosize = X-140
	if(get_theme_font_size("font_size") < tosize && get_theme_font_size("font_size") < 140):
		add_theme_font_size_override('font_size', X-140)
@export var ExpoButton : bool = false

func _on_pressed() -> void:
	print("Button pressed!")
	if(FadeTransition):
		var Transition
		Transition = $"../Transition" if $"../Transition" else $"../../Transition"
		Transition.Anim.play("fade_movement")
		await get_tree().create_timer(1.4).timeout
	if(BUTTON_ACTION == Global.BUTTON_ACTIONS.resume_game && Player):
		Player._pause_game()
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.move_to_level_starting_with):
		#LevelManager.Level = int(text)-1
		LevelManager.change_to_level(int(text)-1, BSide)
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.restart_level):
		Player.TransitionOut.show()
		Player.TransitionOut.fade_out()
		await(get_tree().create_timer(Player.TimeDeath).timeout)
		if get_tree(): get_tree().reload_current_scene()
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.config_menu):
		Edition.CrtFilter = !Edition.CrtFilter
		#print("TO-DO: Lazy developer didn't implement config menu...")
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.move_to_scene):
		if(ExpoButton && Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo_cbb):
			var _scene_string : String = "res://assets/Levels/world1/level1.tscn"
			get_tree().change_scene_to_file(_scene_string)
		elif(Edition.Mobile):
			var _scene_string : String = "res://assets/Levels/world1/level1.tscn"
			get_tree().change_scene_to_file(_scene_string)
		else:
			var _scene_string : String = ADITIONAL_ARGUMENT
			get_tree().change_scene_to_file(_scene_string)
	elif(BUTTON_ACTION == Global.BUTTON_ACTIONS.quit):
		get_tree().quit()


func _on_button_down() -> void:
	_on_pressed()
