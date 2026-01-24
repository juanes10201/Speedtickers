extends Area2D
@export var NeedAction : bool = true 
@export var Action : String = "lobby_initial"
var PlayerEntered : bool = false

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		if(!NeedAction):
			Dialogic.start(Action)
		PlayerEntered = true

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("player_dialog_confirm") && PlayerEntered && Dialogic.current_timeline == null):
		Dialogic.start(Action)
		if(get_parent().is_in_group("Npc")):
			get_parent().Move = false
			Dialogic.timeline_ended.connect(get_parent()._on_timeline_ended)

func _on_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		PlayerEntered = false
