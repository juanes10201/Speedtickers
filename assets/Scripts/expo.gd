extends Node2D


@onready var PlaytimeText = $LimitedTimeUi/PlaytimeText
@onready var PlaytimeTimer : Timer = $PlaytimeTimer

@export var NodeLimitedtimeUi : Node2D
@export var NodeInactiveUi : Node2D

func _ready() -> void:
	if(Edition.GAME_STATUS != Edition.ALL_GAME_STATUS.expo):
		queue_free()
	else:
		show()

var Seconds : String = ""

func _process(delta: float) -> void:
	NodeLimitedtimeUi.visible = Edition.ExpoLimitedTime
	if(LevelManager.ReturnAfterTimerInExpo):
		if(!LevelManager.PlayedExpo && Edition.ExpoLimitedTime):
				LevelManager.ExpoTimer.start()
				LevelManager.PlayedExpo = true
				LevelManager.ExpoTimer.paused = false
		if(LevelManager.ExpoTimer.is_stopped() || LevelManager.ExpoTimer.paused):
			if(LevelManager.ReturnAfterTimerInExpo && LevelManager.ExpoTimer.is_stopped() && LevelManager.PlayedExpo):
				_reset_expo()
			#if(Edition.ExpoLimitedTime):
			#	LevelManager.PlayedExpo = false
		Seconds = str(int(LevelManager.ExpoTimer.time_left) % 60)
		#print(Seconds)
		if(Seconds.length() <= 1): Seconds =  "0" + Seconds
		PlaytimeText.text = " 0" + str(int(LevelManager.ExpoTimer.time_left/60)) + ":" + Seconds
	elif(!LevelManager.ReturnAfterTimerInExpo):
		LevelManager.ExpoTimer.stop()
		LevelManager.PlayedExpo = false
		PlaytimeText.text = ""
	if(!LevelManager.ExpoMoveTimeout.is_stopped() && !LevelManager.ExpoMoveTimeout.paused):
		if(LevelManager.ExpoMoveTimeout.time_left <= 10.0):
			#$inactive_bar.show()
			#$inactive_time.show()
			#$inactive_text.show()
			InRiskTimeout = true
			NodeInactiveUi.show()
			$InactiveUi/inactive_time.text = str(int(ceil(LevelManager.ExpoMoveTimeout.time_left-1)))
			$InactiveUi/inactive_bar.value = LevelManager.ExpoMoveTimeout.time_left-1
		else:
			InRiskTimeout = false
			NodeInactiveUi.hide()
		if(InRiskTimeout && LevelManager.ExpoMoveTimeout.time_left < .5):
			_reset_expo()
	#print(LevelManager.ExpoMoveTimeout.time_left)
		#$inactive_bar.hide()
		#$inactive_time.hide()
		#$inactive_text.hide()
	
	
		
var InRiskTimeout : bool = true

func _reset_expo() -> void:
	print("Reset Expo")
	var _scene_string = "res://assets/Nodes/Ui/main_menu_w_level_preview.tscn"
	Edition.reset_expo()
	get_tree().change_scene_to_file(_scene_string)

func _on_playtime_timeout() -> void:
	print("TIME DONE!")
	_reset_expo()
