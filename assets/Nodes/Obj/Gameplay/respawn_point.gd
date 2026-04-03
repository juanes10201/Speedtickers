extends Area2D
@export var Enabled : bool = false
@export var Id : int = 1

func _ready() -> void:
	if(Enabled || SaveGame.GetRespawn(Id)): _take_play()

func _take_play() -> void:
	SaveGame.get_player().position = self.position


func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		SaveGame.SetRespawn(Id)
