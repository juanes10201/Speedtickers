extends Node2D

var PlayerColliding : bool = false
var Phase2 : bool = false

func _play_anim(Anim : String):
	if(Phase2): $Sprite.play(Anim+"-Phase2")
	else: $Sprite.play(Anim)

func _ready() -> void:
	_play_anim("Intro")
	await get_tree().create_timer(0.05).timeout
	if(Phase2):
		$ExplosionTimerPhase2.start()
	else:
		$ExplosionTimer.start()

func _process(delta: float) -> void:
	if($Sprite.animation == "Intro" && Phase2): _play_anim("Intro")
	if(Phase2):
		$SpriteDamageArea.material.set_shader_parameter("progress", 1-($ExplosionTimerPhase2.time_left/$ExplosionTimerPhase2.wait_time))
	else:
		$SpriteDamageArea.material.set_shader_parameter("progress", 1-($ExplosionTimer.time_left/$ExplosionTimer.wait_time))
	#print($Sprite.speed_scale)
	if($Sprite.animation == "Default" || $Sprite.animation == "Default-Phase2"): $Sprite.speed_scale = .3+$ExplosionTimer.time_left/$ExplosionTimer.wait_time

func _on_explosion_timer_timeout() -> void:
	$Sprite.speed_scale = 1.0
	if(PlayerColliding): SaveGame.get_player().On_Death()
	_play_anim("Explode")
	$SpriteDamageArea.hide()
	$Sprite.z_index += 2
	SaveGame.get_player()._play_sound($AudioExplode)
	await get_tree().create_timer(1.0).timeout
	queue_free()


func _on_explosion_area_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")): PlayerColliding = true


func _on_explosion_area_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")): PlayerColliding = false


func _on_sprite_animation_finished() -> void:
	_play_anim("Default")
