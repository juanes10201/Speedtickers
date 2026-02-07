extends Node2D

var PlayerColliding : bool = false
var Phase2 : bool = false

func _play_anim(Anim : String):
	if(Phase2): $Sprite.play(Anim+"-Phase2")
	else: $Sprite.play(Anim)

func _ready() -> void:
	_play_anim("Intro")

func _process(delta: float) -> void:
	if($Sprite.animation == "Intro" && Phase2): _play_anim("Intro")
	$SpriteDamageArea.material.set_shader_parameter("progress", 1-($ExplosionTimer.time_left/$ExplosionTimer.wait_time))
	#print($Sprite.speed_scale)
	if($Sprite.animation != "Intro"): $Sprite.speed_scale = .3+$ExplosionTimer.time_left/$ExplosionTimer.wait_time

func _on_explosion_timer_timeout() -> void:
	if(PlayerColliding): SaveGame.get_player().On_Death()
	queue_free()


func _on_explosion_area_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")): PlayerColliding = true


func _on_explosion_area_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")): PlayerColliding = false


func _on_sprite_animation_finished() -> void:
	_play_anim("Default")
