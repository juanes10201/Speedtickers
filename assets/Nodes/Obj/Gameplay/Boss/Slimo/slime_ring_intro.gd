extends Area2D

@export var CutOnDistance : bool = false
@export var CutDistance : float = 200.0
@onready var Player = SaveGame.get_player()
@export var OnlyOnce : bool = false
@export var Enabled : bool = true
func _process(delta: float) -> void:
	if(!Enabled): queue_free()
	if($AnimationPlayer.is_playing() && CutOnDistance && position.distance_to(Player.position) >= CutDistance):
		$AnimationPlayer.stop()

func _on_body_entered(body: Node2D) -> void:
	if(!OnlyOnce || !SaveGame.GetDialogue(1) ):
		$AnimationPlayer.play("RingIntro")
