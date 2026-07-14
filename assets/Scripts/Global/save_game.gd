extends Node

var config = ConfigFile.new()
const SAVE_GAME_PATH = "user://savegame.save"

var PlayedIntroBool : bool = false

var CurrentRespawnId : int = 0
var RespawnLevelId : int = 0

var DialoguesIdEnabled : Array[bool] = []
var DialogueLevelId : int = 0
#Random bullshit go!
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

func set_save_value(Category : String, id : String, Val):
	print("Set " + str(Category) + " id: " + id + " to val: " + str(Val))
	config.set_value(Category, id, Val)
	writegamedata()

func set_config_value(id : String, Val) -> void:
	set_save_value("Config", id, Val)

func get_value(sc: String, id : String):
	if(config.get_value(sc, id) != null):
		return config.get_value(sc, id)
	else: return null

func get_config_value(id : String):
	return get_value("Config", id)

func writegamedata() -> void:
	config.save(SAVE_GAME_PATH)
	print("Saved game data!")

func _setup_default_value(sc : String, id : String, val) -> void:
	if(get_value(sc, id) == null):
		print("Setup var " + id + " to " + str(val))
		config.set_value(sc, id, val)

func setup_default_values() -> void:
	#Si fuese un buen programador(boe), aca lo que haria es automatizar esto d alguna forma
	#pero me da paja asi q se queda asi.
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

#La idea es parsear un json a un diccionario en godot.
func SaveLevelPersonalRecord(Level : int = 1, World : int = 1, RealTime : float = 0) -> void:
	loadgamedata()
	setup_default_values()
	
	var _world_name = LevelManager.get_world_name_by_number(World)
	var CurrentBest = get_value(_world_name, str(Level))
	if(!CurrentBest || RealTime < CurrentBest):
		set_save_value(_world_name, str(Level), RealTime)

func SaveLevelRecord(Level : int = 1, World : int = 0, RealTime : float = 0) -> void:
	SaveLevelPersonalRecord(Level, World, RealTime)
	#var CurrentBest : float = get_value("Level", str(Level))
	writegamedata()

func GetLevelTime(Level : int, World : int) -> float:
	var _world_name = LevelManager.get_world_name_by_number(World)
	var CurrentBest = get_value(_world_name, str(Level))
	print("Got time:" + str(CurrentBest) + " of level: " + str(Level) + " and World: " + str(World))
	if(CurrentBest): return CurrentBest
	else: return 0.0

#Los tiempos son de esta forma:
# users: {
#	{
#		time:"", name:"", uuid:""
#	}
#
#}

#Asumimos que estan sorteados en tiempo
var UserTimes : Dictionary = {
	"level0" : {
		"users" : [
			{
				"time": 0.05,
				"name": "pla1",
				"uuid": ""
			},
			{
				"time": 1.00,
				"name": "pla2",
				"uuid": ""
			}
		]
	}
}

func GetLevelTimeDiccionary(level : int) -> Dictionary:
	var s : String = "level"+str(level)
	if(UserTimes.has(s)): return UserTimes[s]
	return {}

func GetUserLevelDiccionary(level : int, index : int) -> Dictionary:
	var LevelDic : Dictionary = GetLevelTimeDiccionary(level)
	if(LevelDic.has("users") && LevelDic["users"].size()-1 >= index):
		return LevelDic["users"][index]
	return {}

func GetPlayerUserName() -> String:
	var name = Steam.getPersonaName()
	if(!name): name = "Player: "
	return name

func boss_slime_play_anim(anim : String) -> void:
	get_boss().play_anim(anim)

func boss_slime_change_portrait(portrait : String) -> void:
	get_boss().set_dialogue_portrait(portrait)
	
func get_boss():
	var Boss = get_tree().get_nodes_in_group("Boss")[0] if get_tree().get_nodes_in_group("Boss").size() else null
	return Boss

func get_player():
	if(get_tree()):
		var Player = get_tree().get_nodes_in_group("Player")[0] if get_tree().get_nodes_in_group("Player").size() else null
		return Player
	else:
		print("WARNING: Tried loading Player before the scene is loaded.")

func get_group_node(Group : String):
	if(get_tree()):
		var GroupTile = get_tree().get_nodes_in_group(Group)[0] if get_tree().get_nodes_in_group(Group).size() else null
		return GroupTile
	else:
		print("WARNING: Tried loading Group Node '" + Group + "' before the scene is loaded.")

func get_player_replay():
	var Player = get_tree().get_nodes_in_group("PlayerReplay")[0] if get_tree().get_nodes_in_group("PlayerReplay").size() else null
	return Player

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
