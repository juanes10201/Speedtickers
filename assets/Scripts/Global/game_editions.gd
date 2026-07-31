extends Node

enum ALL_GAME_STATUS{
	retail,
	expo
}
var ExpoLimitedTime : bool = true

var CrtFilter : bool = true

var GAME_STATUS = ALL_GAME_STATUS.expo

var Is_in_editor : bool = false

var Is_playing_in_editor : bool = false

var DoneIntro = false

var IsErasingInEditor = false

@onready var Mobile : bool = true if OS.get_name() == "Android" else false
