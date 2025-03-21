extends Node


@onready var PlaytimeText = $PlaytimeText
@onready var PlaytimeTimer = $PlaytimeTimer

var time : float = 99

func _ready() -> void:
	if(Edition.GAME_STATUS != Edition.ALL_GAME_STATUS.expo_shangai):
		queue_free()

func _process(delta: float) -> void:
	time = floor((PlaytimeTimer.time_left/60)*100)/100
	PlaytimeText.text = " " + str(time)

func _on_playtime_timeout() -> void:
	print("TIME DONE!")
