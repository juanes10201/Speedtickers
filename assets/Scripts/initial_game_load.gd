extends Node

func _ready():
	print("Initial Game load")
	SaveGame.loadgamedata()
	
	if(SaveGame.get_config_value("Audio_Music")):
		var Audio_Bus_Id = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_volume_db(Audio_Bus_Id, SaveGame.get_config_value("Audio_Music"))
	if(SaveGame.get_config_value("Audio_Sfx")):
		var Audio_Bus_Id = AudioServer.get_bus_index("Sfx")
		AudioServer.set_bus_volume_db(Audio_Bus_Id, SaveGame.get_config_value("Audio_Sfx"))
