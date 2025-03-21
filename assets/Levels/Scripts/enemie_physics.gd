extends CharacterBody2D

#region Setup variables
@export var Enemy_burst_speed : float = 300.0
@export var SPEED : float = 150.0
@export var JUMP_VELOCITY : float = -370.0
@export var SPECIAL_ENEMY_JUMP_VELOCITY : float = -50.0
@export var MAX_FALL_SPEED : float = 300.0
@export var MAX_SPEED : float = 500.0
@export var Cancel_speed : float = 200.0
@export var Max_groundsmash_distance = 300.0
@export var Can_BeGroundSmash : bool = true

#For editor
enum Directions{
	RIGHT,
	LEFT,
	NONE
}

@export var EnemyDirection = Directions.RIGHT
@export var distance : float = 100
@export var enemy_type : float = 0

var OriginalX : float = position.x

var Move : bool = true

var direction = 0 

@onready var Player = $"../Player"
@onready var MoveTimer = $"MoveTimer"
@onready var Sprite = $"Sprite2D"

@onready var MoveSound = Player.AudioSlimeMove if Player else null
@onready var SlideSound = Player.AudioSlimeKill if Player else null
@onready var AudioMove = Player.AudioSlimeMove if Player else null
@onready var AudioGroundsmash = Player.AudioSlimeGroundsmash if Player else null

@onready var ShootBulletTimer = $ShootBulletTimer

@onready var BulletObject = preload("res://assets/Levels/bullets.tscn")# if enemy_type == 2 else null

@export var TimeToShoot : float = 1.0
var was_on_floor : bool = false
var was_on_wall : bool = false

#endregion

#region Killed by Slide or Groundsmash Sound
func _killed_by_player_sound() -> void:
	#if(!SlideSound.playing):
	if(Player):
		Player._play_sound(SlideSound, true)
func _groundsmash_player_sound() -> void:
	if(Player):
		Player._play_sound(AudioGroundsmash, true)
#endregion

#region Jumping
func _jump(_jump_velocity) -> void:
	#The idea is for the enemies to jump when the player does a ground-smash
	if(is_on_floor()): velocity.y = _jump_velocity# * randf_range(1, 1.2)
#endregion

#region Player GroundSmash 
func _on_player_ground_smash_signal() -> void:
	if(Player):
		if(Can_BeGroundSmash && is_on_floor() && global_position.distance_to(Player.position) <= Max_groundsmash_distance):
			_jump(JUMP_VELOCITY if enemy_type == 0 else SPECIAL_ENEMY_JUMP_VELOCITY)
			if(enemy_type == 0):
				$HitParticles.emitting = true
				#Player.FrameFreeze(0.05, 0.4)
				velocity.x = Enemy_burst_speed if Player.position.x < position.x else Enemy_burst_speed*-1
				Move = false
				Player.Controller_Vibrate_Player_Movement(1)
				_groundsmash_player_sound()
#endregion

#region Player Slide 
func _on_player_slide_signal() -> void:
	if(is_on_floor() && enemy_type == 0):
		$HitParticles.emitting = true
		#Player.FrameFreeze(0.05, 0.4)
		_jump(-400)
		Player.Camera.Shake(1.0, 5.0)
		velocity.x = Enemy_burst_speed if  Player.Sliding == Player.Sides.RIGHT else Enemy_burst_speed*-1
		Player.Controller_Vibrate_Player_Movement(1)
		Move = false
		_killed_by_player_sound()
#endregion

func _ready():
	if(EnemyDirection == Directions.RIGHT): direction = 1
	elif(EnemyDirection == Directions.LEFT): direction = -1
	else: direction = 0
	if(ShootBulletTimer): ShootBulletTimer.wait_time = TimeToShoot

#region Physics
func _physics_process(delta: float) -> void:
	if(Player):
		if(is_on_floor() && velocity.x > 0):
			$Moveparticles.emitting = true
		else:
			$Moveparticles.emitting = false
		if(!is_on_floor() && enemy_type == 0):
			$HitFlyParticles.emitting = true
		else:
			$HitFlyParticles.emitting = false
	
	#region Shoot
	if(enemy_type == 2):
		if(ShootBulletTimer.is_stopped() && BulletObject):
			ShootBulletTimer.start()
			var BulletInstance = BulletObject.instantiate()
			BulletInstance.position = self.position
			BulletInstance.top_level = true
			add_child(BulletInstance)
	#endregion
	
	if(Player && Player.EnemiesPhysics):
		if( SPEED != 0 && !is_on_wall()) :
			Sprite.play("Walking")
		else: Sprite.play("Idle")
		
		if(is_on_wall() && !was_on_wall): direction *= -1
		
		#if(is_on_ceiling()): queue_free()
		
		if(velocity.y < 0): strech_size(0.7, 1.3)
		if(velocity.y >= MAX_FALL_SPEED): strech_size(0.5, 1.7)
		
		if(is_on_floor() && was_on_floor == false): strech_size(1.7, 0.5)
		
		_strech_tick(delta)
		
		
		#region Trigger Player GroundSmash
		if(Player && !Player.EnemyGroundSlamTimer.is_stopped()): _on_player_ground_smash_signal()
		#endregion
		#region Gravity
		if (!is_on_floor() &&  velocity.y < MAX_FALL_SPEED):
			velocity += get_gravity() * delta
		#endregion
		if(direction): Sprite.flip_h = false if direction >= 0 else true
		
		#region Horizontal Movement
		#Enemy Movement
		if(Move && Player):
			if (direction && SPEED < MAX_SPEED && SPEED > MAX_SPEED*-1 && MoveTimer.is_stopped()):
				velocity.x = direction * SPEED# * randf_range(1, 1.2)
				strech_size(1.7, 0.5)
				MoveTimer.start()
				Player._play_sound(AudioMove, false)
			elif(!MoveTimer.is_stopped()):
				if(direction > 0): velocity.x -= Cancel_speed*delta
				elif(direction < 0): velocity.x += Cancel_speed*delta
			#if( (direction == 1 && position.x-OriginalX >= distance) || (direction == -1 && position.x-OriginalX < distance*-1) ):
			#	direction *= -1
		else:
			if(velocity.x > 0): velocity.x -= Cancel_speed*delta
			elif(velocity.x < 0): velocity.x += Cancel_speed*delta
		#endregion
		was_on_floor = is_on_floor()
		was_on_wall = is_on_wall()
		move_and_slide()
#endregion

#region Scaling
@onready var original_scale = Sprite.scale
func strech_size(X, Y):
	Sprite.scale = Vector2(original_scale.x*X, original_scale.y*Y)

func _strech_tick(delta : float):
	Sprite.scale.x += (original_scale.x - Sprite.scale.x) * 15 * delta
	Sprite.scale.y += (original_scale.y - Sprite.scale.y) * 15 * delta
#endregion

#region toggle collision
func enable_collision() -> void:
	#Enable
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)
	
	set_collision_mask_value(2, false)
	set_collision_layer_value(2, false)

func disable_collision() -> void:
	#Disable
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
		
	set_collision_mask_value(2, true)
	set_collision_layer_value(2, true)

func toggle_collision() -> void:
	#Disable
	if(get_collision_mask_value(1)):
		set_collision_mask_value(1, false)
		set_collision_layer_value(1, false)
		
		set_collision_mask_value(2, true)
		set_collision_layer_value(2, true)
	else:
		#Enable
		set_collision_mask_value(1, true)
		set_collision_layer_value(1, true)
		
		set_collision_mask_value(2, false)
		set_collision_layer_value(2, false)
#endregion
#region Check collision
func check_collision() -> bool:
	if(get_collision_mask_value(1)): return true
	else: return false
#endregion
#region Enemie Death
func On_Death():
	#region Create destroy particles
	if(enemy_type == 0):
		var DestroyParticles = preload("res://assets/Levels/Particles/destroy_enemy.tscn")
		var InstanceParticles = DestroyParticles.instantiate()
		get_tree().current_scene.add_child(InstanceParticles)
		InstanceParticles.position = self.position
	elif(enemy_type == 1):
		var DestroyParticles = preload("res://assets/Levels/Particles/destroy_enemy_special.tscn")
		var InstanceParticles = DestroyParticles.instantiate()
		get_tree().current_scene.add_child(InstanceParticles)
		InstanceParticles.position = self.position
	#endregion
	self.queue_free()
#endregion
