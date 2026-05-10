extends Node2D

@export var AudioIdle : AudioStreamPlayer

@onready var Player = SaveGame.get_player()

var ShootingAmount : int = 0
var Shooting : bool = false

func _process(delta: float) -> void:
	print(ShootingAmount)
	if(Shooting && ShootingAmount <= 0):
		Shooting = false
		Player._fade_sound(AudioIdle)
		

func spawn_proyectiles() -> void:
	ShootingAmount = 0
	Player._play_sound(AudioIdle)
	for Proyectile in get_children():
		if(get_tree() && Proyectile is Area2D):
			await get_tree().create_timer(0.2).timeout
			ShootingAmount += 1
			Proyectile.restart()
			Shooting = true
