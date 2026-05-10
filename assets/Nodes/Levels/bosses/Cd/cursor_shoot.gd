extends Node2D

var Shooting : bool = false
@export var ShootCooldown : Timer
@export var Player : CharacterBody2D

var ShootMoveXNum : int = 0
const ShootMoveXMax : int = 4

func _ready() -> void:
	pass # Replace with function body.

func shoot() -> void:
	ShootCooldown.start()
	for Bullet in get_children():
		if(Bullet is Area2D && !Bullet.Enabled):
			Bullet.shoot(Player.LastDirection, Player.global_position, ShootMoveXNum)
			ShootMoveXNum += 1
			if(ShootMoveXNum > ShootMoveXMax): ShootMoveXNum = 0
			return

func _shoot_tick(delta : float) -> void:
	Shooting = Input.is_action_pressed("player_shoot")
	if(Shooting && ShootCooldown.is_stopped()):
		shoot()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_shoot_tick(delta)
