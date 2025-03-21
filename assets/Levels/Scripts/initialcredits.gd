extends AnimatedSprite2D
@onready var NextTimer = $"../Timer"
@export var level_to_change = "level1"
@export var main_menu_scene = "main_menu"
@export var menu_expo_scene = "main_menu_expo"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.play()
	#Set fullscreen when on browser
	if(OS.get_name() == "Web"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(NextTimer.is_stopped()):
		#if it's the first time changes scene to level 1 directly
		var _scene_string : String = ""
		var FirstTimePlayed : bool = SaveGame.IfPlayedFirstTime()
		print(FirstTimePlayed)
		if(!FirstTimePlayed || Edition.GAME_STATUS == Edition.ALL_GAME_STATUS.expo_shangai):
			_scene_string = "res://assets/Levels/world1/" + level_to_change + ".tscn"
		else:
			_scene_string= "res://assets/Levels/world1/" + main_menu_scene + ".tscn"
		get_tree().change_scene_to_file(_scene_string)
