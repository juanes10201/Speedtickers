extends Area2D

@export var BossCd : Node2D
@onready var Player = SaveGame.get_player()
@export var TimeShoot : float = .7

func _on_body_entered(body: Node2D) -> void:
	if(BossCd && body.is_in_group("Player")):
		BossCd._shoot_pos(BossCd._predict_mov(Player.global_position, Player.velocity, TimeShoot), TimeShoot)
