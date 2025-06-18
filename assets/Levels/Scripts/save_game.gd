extends Node

var config = ConfigFile.new()
const SAVE_GAME_PATH = "user://savegame.save"

func IfPlayedFirstTime() -> bool:
	loadgamedata()
	var playedbefore = config.get_value("Game", "PlayedBefore")
	if(playedbefore == "true"):
		return true
	else:
		config.set_value("Game", "PlayedBefore", "true")
	return false

func get_player():
	var Player = get_tree().get_nodes_in_group("Player")[0] if get_tree().get_nodes_in_group("Player").size() else null
	return Player

func savelevelrecord(Level : float = 1, RealTime : float = 0) -> void:
	loadgamedata()
	var current_best_score = config.get_value("Level", str(Level))
	if(current_best_score != null && RealTime < current_best_score):
		config.set_value("Level", str(Level), RealTime)
	print("Saved data of level!")
	writegamedata()
	
func writegamedata() -> void:
	config.save(SAVE_GAME_PATH)
	print("Saved game data!")

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
	print("loaded game saved data!")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
