extends CanvasLayer

enum PauseButtons{
	RESUME_GAME,
	CONFIG,
	RESTART
}
var SelectedButton = null

@onready var Transition = $"Transition"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#If connected controller
	if(!Input.get_connected_joypads().size() == 0):
		SelectedButton = PauseButtons.RESUME_GAME
	SongPlayer.MusicState = SongPlayer.MusicStates.menu

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_pressed("ui_click")):
		SelectedButton = null
	if(Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_right")):
		if(SelectedButton == PauseButtons.RESUME_GAME): SelectedButton = PauseButtons.CONFIG
		elif(SelectedButton == PauseButtons.CONFIG): SelectedButton = PauseButtons.RESTART
		else: SelectedButton = PauseButtons.RESUME_GAME
	elif(Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_left")):
		if(SelectedButton == PauseButtons.RESUME_GAME): SelectedButton = PauseButtons.RESTART
		elif(SelectedButton == PauseButtons.CONFIG): SelectedButton = PauseButtons.RESUME_GAME
		else: SelectedButton = PauseButtons.CONFIG
	if(SelectedButton != null):
		if(SelectedButton == PauseButtons.RESUME_GAME): $PauseMenuButton2.grab_focus()
		elif(SelectedButton == PauseButtons.CONFIG): $PauseMenuConfigButton2.grab_focus()
		else: $PauseMenuGoBackButton2.grab_focus()
