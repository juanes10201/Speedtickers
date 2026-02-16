extends Node

var config = ConfigFile.new()
const SAVE_GAME_PATH = "user://savegame.save"

var PlayedIntroBool : bool = false

var CurrentRespawnId : int = 0
var RespawnLevelId : int = 0

var DialoguesIdEnabled : Array[bool] = []
var DialogueLevelId : int = 0

func PlayedIntro() -> bool:
	return PlayedIntroBool

func IfPlayedFirstTime() -> bool:
	loadgamedata()
	var playedbefore = config.get_value("Game", "PlayedBefore")
	if(playedbefore == "true"):
		return true
	else:
		config.set_value("Game", "PlayedBefore", "true")
	return false

func set_config_value(id : String, Val) -> void:
	print("Set config id: " + id + " to val: " + str(Val))
	config.set_value("Config", id, Val)
	writegamedata()

func get_value(sc: String, id : String):
	if(config.get_value(sc, id) != null):
		return config.get_value(sc, id)

func get_config_value(id : String):
	if(config.get_value("Config", id) != null):
		return config.get_value("Config", id)

func writegamedata() -> void:
	config.save(SAVE_GAME_PATH)
	print("Saved game data!")

func _setup_default_value(sc : String, id : String, val) -> void:
	if(get_value(sc, id) == null):
		print("Setup var " + id + " to " + str(val))
		config.set_value(sc, id, val)

func setup_default_values() -> void:
	_setup_default_value("Config", "AudioMusic", 1)
	_setup_default_value("Config", "AudioSfx", 1)
	_setup_default_value("Config", "Fullscreen", 0)
	_setup_default_value("Config", "Shake", 1)
	_setup_default_value("Config", "PixelPerfect", 0)
	_setup_default_value("Config", "Juice", 1)
	_setup_default_value("Config", "Particles", 1)
	_setup_default_value("Config", "CrtShader", 1)
	_setup_default_value("Config", "Cheats", 0)
	_setup_default_value("Config", "DisableTimer", 0)
	_setup_default_value("Config", "GodMode", 0)
	_setup_default_value("Config", "UnlockAll", 0)
	_setup_default_value("Config", "ShowHitboxes", 0)
	writegamedata()

func savelevelrecord(Level : float = 1, RealTime : float = 0) -> void:
	loadgamedata()
	setup_default_values()
	var current_best_score = config.get_value("Level", str(Level))
	if(current_best_score != null && RealTime < current_best_score):
		config.set_value("Level", str(Level), RealTime)
	print("Saved data of level!")
	writegamedata()

func get_player():
	var Player = get_tree().get_nodes_in_group("Player")[0] if get_tree().get_nodes_in_group("Player").size() else null
	return Player

func get_player_replay():
	var Player = get_tree().get_nodes_in_group("PlayerReplay")[0] if get_tree().get_nodes_in_group("PlayerReplay").size() else null
	return Player

func getleveltime(Level : float) -> float:
	var leveltime = config.get_value("Level", str(Level))
	print("Got time:" + str(leveltime) + " of level: " + str(Level))
	if(!leveltime): return 0.0
	return leveltime

func loadgamedata() -> void:
	var err = config.load(SAVE_GAME_PATH)
	if(err == OK):
		#Here put values given savefile
		pass
	setup_default_values()
	print("loaded game saved data!")

func SetDialogue(Id : int, Level : int = LevelManager.get_level()) -> void:
	print("Set Dialogue")
	if(Level != DialogueLevelId):
		DialoguesIdEnabled = []
		DialogueLevelId = Level
	if(Id > DialoguesIdEnabled.size()-1): DialoguesIdEnabled.resize(Id+1)
	DialoguesIdEnabled[Id] = true

func GetRespawn(Id : int) -> bool:
	print("Get respawn")
	return RespawnLevelId == LevelManager.get_level() && CurrentRespawnId == Id

func GetDialogue(Id : int) -> bool:
	#print("Get dialogue Id: " + str(Id) + " to " + str(DialoguesIdEnabled[Id]))
	return (DialogueLevelId == LevelManager.get_level() && DialoguesIdEnabled.size()-1 >= Id && DialoguesIdEnabled[Id] == true)

func SetRespawn(Id : int, Level : int = LevelManager.get_level()) -> void:
	CurrentRespawnId = Id
	RespawnLevelId = Level
