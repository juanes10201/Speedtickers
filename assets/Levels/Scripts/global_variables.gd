extends Node

enum KillBoxTypes{
	Red,
	Blue
}
enum BUTTON_ACTIONS{
	none,
	resume_game,
	restart_level,
	config_menu,
	move_to_scene,
	move_to_level_starting_with
}
enum OBJECT_ACTIONS{
	none,
	switch_killbox_type,
	MoveLava,
	Switch_Player_Gravity,
	Switch_Gravity_Remix
}
enum GravityDirections{
	INVERTED = -1,
	MAIN = 1
}

var Player = null

#Order of levels
@export var LevelOrder: Array[PackedScene]

var Level : int = -99

func get_level() -> int:
	return Level

func change_to_level(Lvl : int) -> void:
	get_tree().change_scene_to_packed(LevelOrder[Lvl])

func _ready():
	var Player = SaveGame.get_player()

func Play_Global_Action(Action : OBJECT_ACTIONS):
	Player = SaveGame.get_player() 
	if(!Player): return
	if(Action == Global.OBJECT_ACTIONS.switch_killbox_type):
		if(Player.EnabledKillBox == Global.KillBoxTypes.Red):
			Player.EnabledKillBox = Global.KillBoxTypes.Blue
		else:
			Player.EnabledKillBox = Global.KillBoxTypes.Red
	elif(Action == Global.OBJECT_ACTIONS.MoveLava):
		Player.MoveLava = true
	elif(Action == OBJECT_ACTIONS.Switch_Player_Gravity):
		Player._invert_gravity()
	elif(Action == OBJECT_ACTIONS.Switch_Gravity_Remix):
		Player._invert_gravity_remix()
