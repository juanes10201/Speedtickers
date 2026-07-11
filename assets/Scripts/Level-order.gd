extends Node

#Order of levels

@export var LevelsCsvPath : String
var LevelPaths : Dictionary 
var WorldOrder : Array[String]
var AmountLevels : int = 0

@onready var ExpoTimer = $ExpoTimer
var PlayedExpo : bool = false
var ReturnAfterTimerInExpo : bool = true
@onready var StyleTimer = $StyleTimer

@onready var ExpoMoveTimeout : Timer = $ExpoMoveTimeout

var PreviousStyle : String = "D"
var PreviousScore : String = ""

func _ready() -> void:
	load_level_csv()

func load_level_csv():
	var filecsv = FileAccess.open(LevelsCsvPath, FileAccess.READ)
	var filetxt = filecsv.get_as_text()
	AmountLevels = 0
	#Iterate throught every line
	for i in range(filetxt.get_slice_count("\n") ):
		var _line = filetxt.get_slice("\n", i)
		for l in range(_line.get_slice_count(",")):
			var _value = _line.get_slice(",", l)
			if(_value == "" || _value == ","): continue
			#If the value is in the first line, then use it to create the dictionaries
			#estoy gaga no se pq a veces escribo en ingles y otras en español. ups
			if(i == 0):
				LevelPaths.set(_value, [])
				WorldOrder.append(_value)
			elif(l < WorldOrder.size()):
				AmountLevels += 1
				LevelPaths[WorldOrder[l]].append(_value)
	print("Reloaded level paths csv file")
	#print(LevelPaths)

func get_world_by_number(world : int) -> Array:
	return LevelPaths[WorldOrder[world]]

func get_total_number_level(level : int, world : int) -> int:
	var PrevWorldsSize : int = 0
	for i in range(world):
		if(i < 0): break
		PrevWorldsSize += LevelPaths[WorldOrder[i]].size()
	return PrevWorldsSize+level

func get_world_number(world : String) -> int:
	return WorldOrder.find(world)

func get_amount_levels_in_world(world : int) -> int:
	return LevelPaths[WorldOrder[world]].size()

func get_level_time():
	var Player = get_tree().get_nodes_in_group("GameTimer")[0] if get_tree().get_nodes_in_group("GameTimer").size() else null
	return Player

func change_to_next_level() -> void:
	if(Global.Level+1 > LevelPaths[WorldOrder[Global.World]].size() ):
		change_to_level(0, Global.World + 1)
	else:
		change_to_level(Global.Level+1, Global.World)

func get_level() -> int:
	return Global.Level

func change_to_level(Level : int , World : int) -> void:
	if(World < WorldOrder.size()):
		var CurrentWorld : String = WorldOrder[World]
		Global.World = World
		change_to_level_world_string(Level, CurrentWorld)

func get_level_path(Level : int, World : String) -> String:
	return "res://assets/Nodes/Levels/" + str(World) + "/" + str(LevelPaths[World][Level])

func change_to_level_world_string(Level : int, World : String) -> void:
	Global.Level = Level
	Global.World = get_world_number(World)
	if(Level <= 0): Global.Level = 1
	if(Level >= LevelPaths[World].size()):
		Level = 0
		World = WorldOrder[get_world_number(World)+1]
	var SceneString : String = get_level_path(Level, World)
	print("Changing to level " + str(Level) + " World: " + str(World))
	print("Path: " + SceneString)
	change_scene(SceneString)

func change_scene(Scene : String) -> void:
	get_tree().change_scene_to_file(Scene)

var StyloMetter : int = 5 
var StyloString : String = "B"

enum Styles{
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
	var _player = SaveGame.get_player()
	if(_player && !_player.Styleometter): return
	StyloMetter -= Qt
	if(StyloMetter < 0): StyloMetter = 0
	ScoreMult = 1

func AddStyle(Qt : int, Moto : String = "", Mult : float = 1.0):
	#Score Multiplier
	var _player = SaveGame.get_player()
	if(_player && !_player.Styleometter): return
	StyleMultiplierTimer.start()
	if(Moto == StyleMoto):#!=1
		PointsLeftMult -= 1
		#if(PointsLeftMult <= 0):
		if(ScoreMult < 3):
			ScoreMult += 1
			#PointsLeftMult = 5
			if(ScoreMult == 3):
				#SaveGame.get_player().FrameFreeze(.3, .2)
				var Player = SaveGame.get_player()
				if(Player):
					#Player._play_sound(Player.AudioUpgrade)
					if(Player.Camera):
						Player.Camera.Shake(12.0, 12.0, true)
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
