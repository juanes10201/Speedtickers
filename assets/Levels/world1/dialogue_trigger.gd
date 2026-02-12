extends Area2D
@export var NeedAction : bool = true 
@export var Action : String = "lobby_initial"
var PlayerEntered : bool = false
@export var PauseGame : bool = false
@onready var Player = SaveGame.get_player()
@export var OnlyOnce : bool = false
var TimeDone : int = 0

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
	#	if(!NeedAction):
	#		Dialogic.start(Action)
	#		if(get_parent().is_in_group("Npc")):
	#			Dialogic.timeline_ended.connect(get_parent()._on_timeline_ended)
	#		if(PauseGame):
	#			Player._pause_game_no_menu()
		PlayerEntered = true

func _process(delta: float) -> void:
	if((!NeedAction || Input.is_action_just_pressed("player_dialog_confirm")) && PlayerEntered && Dialogic.current_timeline == null):
		if(TimeDone > 0 && OnlyOnce): return
		TimeDone += 1
		if(PauseGame):
			Player._pause_game_no_menu()
		Dialogic.start(Action)
		if(get_parent().is_in_group("Npc")):
			Dialogic.timeline_ended.connect(get_parent()._on_timeline_ended)
			get_parent().Move = false

func _on_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		PlayerEntered = false
