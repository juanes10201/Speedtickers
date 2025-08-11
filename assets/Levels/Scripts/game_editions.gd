extends Node

enum ALL_GAME_STATUS{
	retail,
	expo_shangai,
	expo_cbb
}

var GAME_STATUS = ALL_GAME_STATUS.retail

var Is_in_editor : bool = false

var Is_playing_in_editor : bool = false

var DoneIntro = false

var IsErasingInEditor = false

@onready var Mobile : bool = true if OS.get_name() == "Android" else false
