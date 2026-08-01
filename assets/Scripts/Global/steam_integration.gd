extends Node

const AppID : String = "3822390"
var CurrentLeaderboardHandle : int

func _init() -> void:
	Steam.leaderboard_find_result.connect(leaderboard_found)

func _ready() -> void:
	initialize_steam()
	leaderbord_find("LowestTimes")

var DidSteamInitialize : bool = false

func initialize_steam() -> void:
	if(!Edition.SteamEnabled):
		print("EDITION: DOES NOT HAVE STEAM ENABLED")
		DidSteamInitialize = false
		return
	else:
		var initialize_response: Dictionary = Steam.steamInitEx()
		print("Did Steam initialize?: %s " % initialize_response)
		DidSteamInitialize = !initialize_response["status"]

func leaderbord_find(handle : String):
	Steam.findLeaderboard(handle)

func leaderboard_found(leadboard, found : bool) -> void:
	if(found):
		print("Found leaderboard id: " + str(leadboard))
		CurrentLeaderboardHandle = leadboard
	else:
		print("Couldn't find leaderboard id: " + str(leadboard))
