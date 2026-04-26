extends StaticBody2D
@export var XSpeed : float = 200.0
@export var Direction : Global.GravityDirections = Global.GravityDirections.MAIN
@export var Moving : bool = false

var CollidedPlayer : bool= false
@onready var Player = SaveGame.get_player()

func _process(delta: float) -> void:
	if(Moving):
		position.x += XSpeed *delta


func _on_player_area_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		Moving = true
		CollidedPlayer = true
		Player.StickOnPlatform = true


func _on_player_area_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		CollidedPlayer = false
		Player.StickOnPlatform = false


func _on_destroy_area_body_entered(body: Node2D) -> void:
	if(Moving):
		queue_free()
