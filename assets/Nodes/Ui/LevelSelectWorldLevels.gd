extends Node2D

@export var CurrentWorldLabel : RichTextLabel
@export var PreviousButton : Button
@export var NextButton : Button

@export var AmountLevelsLabel : RichTextLabel

@export var Transition : Node2D

var Page : int = 0
var CurrentWorld : int = 0
#The amount of buttons per page
var AmountButtons : int = 0

var Bside : bool = false

func _switch_bside() -> void:
	if(!Bside):
		_bside_start()
	else:
		_bside_end()

func _bside_start() -> void:
	Transition.Anim.play("BSide_start")
	Page = 0
	CurrentWorld = 0
	Bside = true
	_reload_page()

func _bside_end() -> void:
	Transition.Anim.play("BSide_end")
	Page = 0
	CurrentWorld = 0
	Bside = false
	_reload_page()

func _ready() -> void:
	AmountButtons = get_child_count()
	_reload_page()

func _reload_page() -> void:
	if(Page < 0):
		CurrentWorld -= 1
		if(CurrentWorld < 0): CurrentWorld = 0
		Page = LevelManager.get_amount_levels_in_world(CurrentWorld, Bside)/AmountButtons
	if(Page*AmountButtons > LevelManager.get_amount_levels_in_world(CurrentWorld, Bside)):
		Page = 0
		CurrentWorld += 1
	
	CurrentWorld = clamp(CurrentWorld, 0, LevelManager.get_world_order(Bside).size()-1)
	
	PreviousButton.visible = !(CurrentWorld == 0 && Page == 0)
	NextButton.visible = !(CurrentWorld == LevelManager.get_world_order(Bside).size()-1 && Page*AmountButtons+AmountButtons > floor(LevelManager.get_amount_levels_in_world(CurrentWorld, Bside)) )
	
	#print(CurrentWorld == LevelManager.WorldOrder.size()-1)
	#print(Page*AmountButtons)
	#print(LevelManager.get_amount_levels_in_world(CurrentWorld))
	
	if(CurrentWorldLabel):
		CurrentWorldLabel.text = "WORLD " + str(CurrentWorld+1)
		if(Bside):
			CurrentWorldLabel.text = "?" + CurrentWorldLabel.text
	
	var _count : int = Page*AmountButtons
	var _internal_count : int = 0
	for button in get_children():
		if(button is not Button): continue
		button.ADITIONAL_ARGUMENT = LevelManager.get_world_order(Bside)[CurrentWorld]
		if(_count >= LevelManager.get_amount_levels_in_world(CurrentWorld, Bside) ):
			button.hide()
		else:
			button.show()
			if(AmountLevelsLabel):
				AmountLevelsLabel.text = str(LevelManager.get_total_number_level(Page*AmountButtons+_internal_count+1, CurrentWorld, Bside) ) + "/" + str(LevelManager.get_amount_total_levels(Bside)+1)
		button.text = str(_count+1)
		
		_internal_count += 1
		_count += 1

func _change_buttons_anim() -> void:
	if(Transition): Transition.Anim.play("change_select_buttons")

func _change_page(_page : int) -> void:
	Page = _page
	_change_buttons_anim()
	_reload_page()

#Next world
func _on_pause_menu_button_2_button_down() -> void:
	_change_page(Page+1)

#Previous world
func _on_pause_menu_button_3_button_down() -> void:
	_change_page(Page-1)
