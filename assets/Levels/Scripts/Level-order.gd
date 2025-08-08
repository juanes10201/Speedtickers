extends Node

#Order of levels
@export var LevelOrder: Array[PackedScene]
@onready var ExpoTimer = $ExpoTimer
var PlayedExpo : bool = false
var ReturnAfterTimerInExpo : bool = true

func get_level() -> int:
	return Global.Level

func change_to_level(Lvl : int) -> void:
	Global.Level = Lvl
	print("Changing to level " + str(Lvl))
	if(Lvl <= 0): Global.Level = 1
	get_tree().change_scene_to_packed(LevelOrder[Lvl])
