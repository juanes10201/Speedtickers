extends Node


@onready var PlaytimeText = $PlaytimeText
@onready var PlaytimeTimer : Timer = $PlaytimeTimer

var time : float = 99

func _ready() -> void:
	if(Edition.GAME_STATUS != Edition.ALL_GAME_STATUS.expo_cbb):
		queue_free()

func _process(delta: float) -> void:
	if(LevelManager.ReturnAfterTimerInExpo && LevelManager.ExpoTimer.is_stopped()):
		if(!LevelManager.PlayedExpo):
			LevelManager.ExpoTimer.start()
			LevelManager.PlayedExpo = true
		elif(LevelManager.ReturnAfterTimerInExpo):
			var _scene_string = "res://assets/Levels/world1/main_menu_w_level_preview.tscn"
			get_tree().change_scene_to_file(_scene_string)
	if(!LevelManager.ReturnAfterTimerInExpo):
		LevelManager.ExpoTimer.stop()
		LevelManager.PlayedExpo = false
	time = floor((LevelManager.ExpoTimer.time_left/60)*100)/100
	PlaytimeText.text = " " + str(time)

func _on_playtime_timeout() -> void:
	print("TIME DONE!")
