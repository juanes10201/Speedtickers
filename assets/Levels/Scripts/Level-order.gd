extends Node

#Order of levels
@export var LevelOrder: Array[PackedScene]
@export var LevelOrderBsides : Array[PackedScene]
@onready var ExpoTimer = $ExpoTimer
var PlayedExpo : bool = false
var ReturnAfterTimerInExpo : bool = true
@onready var StyleTimer = $StyleTimer

@onready var ExpoMoveTimeout : Timer = $ExpoMoveTimeout

var PreviousStyle : String = "D"
var PreviousScore : String = ""

func get_level_time():
	var Player = get_tree().get_nodes_in_group("GameTimer")[0] if get_tree().get_nodes_in_group("GameTimer").size() else null
	return Player

func get_level() -> int:
	return Global.Level

func change_to_level(Lvl : int, Bside : bool = false) -> void:
	Global.Level = Lvl
	print("Changing to level " + str(Lvl))
	if(Lvl <= 0): Global.Level = 1
	if(!Bside):
		if(Lvl < LevelOrder.size()):
			get_tree().change_scene_to_packed(LevelOrder[Lvl])
	else:
		if(Lvl < LevelOrderBsides.size()):
			get_tree().change_scene_to_packed(LevelOrderBsides[Lvl])

var StyloMetter : int = 5 
var StyloString : String = "B"

enum Styles{
	please_dont_sue_me = 10000,
	P = 1500,
	SSS = 1000,
	SS = 900,
	S = 500,
	A = 400,
	B = 250,
	C = 100,
	D = 0
}

@export var StyleAmounts: Array[int] = [10, 20, 100, 200, 400, 600]

var StyleMoto : String = ""

var ScoreMult : int = 1

var StylePlayedHideAnimation : bool = true

var LastScore : int = 0

var PointsLeftMult = 5

@onready var StyleMultiplierTimer = $StyleMultiplierTimer 

func RemoveStyle(Qt : int, Moto : String = ""):
	if(!SaveGame.get_player().Styleometter): return
	StyloMetter -= Qt
	if(StyloMetter < 0): StyloMetter = 0
	ScoreMult = 1

func AddStyle(Qt : int, Moto : String = "", Mult : float = 1.0):
	#Score Multiplier
	if(!SaveGame.get_player().Styleometter): return
	StyleMultiplierTimer.start()
	if(Moto == StyleMoto):#!=1
		PointsLeftMult -= 1
		#if(PointsLeftMult <= 0):
		if(ScoreMult < 3):
			ScoreMult += 1
			#PointsLeftMult = 5
			if(ScoreMult == 3):
				#SaveGame.get_player().FrameFreeze(.3, .2)
				SaveGame.get_player().Camera.Shake(12.0, 12.0, true)
	StyloMetter += StyleAmounts[Qt] * ScoreMult * Mult
	StyleMoto = Moto
	if(StyloMetter < 0): StyloMetter = 0
	StyleTimer.start()
	LastScore = StyleAmounts[Qt] * ScoreMult * Mult

func GetStyle() -> String:
	#The styles are sorted from biggest to lowest
	#So we search for the first one that the Style >=, and return the name
	for i in range(Styles.values().size()):
		if StyloMetter >= Styles.values()[i]:
			StyloString = Styles.keys()[i]
			break
	return StyloString

var StyleTimeOut : int = 40

func _on_style_timer_timeout() -> void:
	StyleMoto = ""
	RemoveStyle(StyleTimeOut)


func _on_style_multiplier_timer_timeout() -> void:
	ScoreMult = 1
