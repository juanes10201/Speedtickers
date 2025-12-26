extends Node2D

func _ready() -> void:
	$ParticleDestroy1.emitting = true
	$ParticleDestroy2.emitting = true
	$ParticleDestroy3.emitting = true
	$ParticleDestroy4.emitting = true
	$GPUParticles2D.emitting = true

func _on_destroy_timer_timeout() -> void:
	queue_free()
