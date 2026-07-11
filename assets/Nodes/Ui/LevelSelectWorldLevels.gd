extends Node2D

@export var CurrentWorldLabel : RichTextLabel
@export var PreviousButton : Button
@export var NextButton : Button

@export var AmountLevelsLabel : RichTextLabel

var Page : int = 0
var CurrentWorld : int = 0
#The amount of buttons per page
var AmountButtons : int = 0

func _ready() -> void:
	AmountButtons = get_child_count()
	_reload_page()

func _reload_page() -> void:
	if(Page < 0):
		CurrentWorld -= 1
		if(CurrentWorld < 0): CurrentWorld = 0
		Page = LevelManager.get_amount_levels_in_world(CurrentWorld)/AmountButtons
	if(Page*AmountButtons > LevelManager.get_amount_levels_in_world(CurrentWorld)):
		Page = 0
		CurrentWorld += 1
	
	CurrentWorld = clamp(CurrentWorld, 0, LevelManager.WorldOrder.size()-1)
	
	PreviousButton.visible = !(CurrentWorld == 0 && Page == 0)
	NextButton.visible = !(CurrentWorld == LevelManager.WorldOrder.size()-1 && Page*AmountButtons+AmountButtons > floor(LevelManager.get_amount_levels_in_world(CurrentWorld)) )
	
	#print(CurrentWorld == LevelManager.WorldOrder.size()-1)
	#print(Page*AmountButtons)
	#print(LevelManager.get_amount_levels_in_world(CurrentWorld))
	
	if(CurrentWorldLabel):
		CurrentWorldLabel.text = "WORLD " + str(CurrentWorld+1)
	
	var _count : int = Page*AmountButtons
	var _internal_count : int = 0
	for button in get_children():
		if(button is not Button): continue
		button.ADITIONAL_ARGUMENT = LevelManager.WorldOrder[CurrentWorld]
		if(_count >= LevelManager.get_amount_levels_in_world(CurrentWorld) ):
			button.hide()
		else:
			button.show()
			if(AmountLevelsLabel):
				AmountLevelsLabel.text = str(LevelManager.get_total_number_level(Page*AmountButtons+_internal_count+1, CurrentWorld)) + "/" + str(LevelManager.AmountLevels+1)
		button.text = str(_count+1)
		
		_internal_count += 1
		_count += 1

func _change_page(_page : int) -> void:
	Page = _page
	_reload_page()

#Next world
func _on_pause_menu_button_2_button_down() -> void:
	_change_page(Page+1)

#Previous world
func _on_pause_menu_button_3_button_down() -> void:
	_change_page(Page-1)
