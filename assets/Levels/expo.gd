extends Node


@onready var PlaytimeText = $PlaytimeText
@onready var PlaytimeTimer : Timer = $PlaytimeTimer

func _ready() -> void:
	if(Edition.GAME_STATUS != Edition.ALL_GAME_STATUS.expo_cbb):
		queue_free()

var Seconds : String = ""

func _process(delta: float) -> void:
	if(LevelManager.ReturnAfterTimerInExpo):
		if(LevelManager.ExpoTimer.is_stopped()):
			if(!LevelManager.PlayedExpo):
				LevelManager.ExpoTimer.start()
				LevelManager.PlayedExpo = true
			elif(LevelManager.ReturnAfterTimerInExpo):
				var _scene_string = "res://assets/Levels/world1/main_menu_w_level_preview.tscn"
				get_tree().change_scene_to_file(_scene_string)
		Seconds = str(int(LevelManager.ExpoTimer.time_left) % 60)
		print(Seconds)
		if(Seconds.length() <= 1): Seconds =  "0" + Seconds
		PlaytimeText.text = " 0" + str(int(LevelManager.ExpoTimer.time_left/60)) + ":" + Seconds
	elif(!LevelManager.ReturnAfterTimerInExpo):
		LevelManager.ExpoTimer.stop()
		LevelManager.PlayedExpo = false
		PlaytimeText.text = ""


func _on_playtime_timeout() -> void:
	print("TIME DONE!")
