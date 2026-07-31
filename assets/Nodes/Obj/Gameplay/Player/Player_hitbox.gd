extends Area2D

@onready var Player : CharacterBody2D = SaveGame.get_player()
@onready var HitboxMain : CollisionShape2D = $CollisionShapeMain
@onready var HitboxDash : CollisionShape2D = $CollisionShapeDash

func _physics_process(delta: float) -> void:
	if(HitboxDash && Player):
		HitboxDash.disabled = Player.DashTime.is_stopped()
		HitboxMain.disabled = !Player.DashTime.is_stopped()
