extends Node2D

var PlayerColliding : bool = false

func _process(delta: float) -> void:
	$SpriteDamageArea.material.set_shader_parameter("progress", 1-($ExplosionTimer.time_left/$ExplosionTimer.wait_time))

func _on_explosion_timer_timeout() -> void:
	if(PlayerColliding): SaveGame.get_player().On_Death()
	queue_free()


func _on_explosion_area_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")): PlayerColliding = true


func _on_explosion_area_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")): PlayerColliding = false
