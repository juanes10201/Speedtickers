extends CharacterBody2D

#region Setup variables
@export_group("Custom")
@export var RetroStyle : bool = false
@export var Activate_on_color : Global.LASER_COLORS = Global.LASER_COLORS.NONE
@export var enemy_type : float = 0
@export var EnemyDirection : Directions = Directions.RIGHT
@export var distance : float = 100
@export var GravityDirection : Global.GravityDirections = Global.GravityDirections.MAIN
@export var TimeToShoot : float = 1.0

@export_group("Physics")
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

var OriginalX : float = position.x

var Move : bool = true

var direction = 0 

@onready var Player : ClassPlayer = SaveGame.get_player()
@onready var MoveTimer : Timer = $"MoveTimer"
@onready var Sprite : AnimatedSprite2D = $"Sprite2D"

@onready var MoveSound : AudioStreamPlayer = Player.AudioSlimeMove if Player else null
@onready var SlideSound : AudioStreamPlayer = Player.AudioSlimeKill if Player else null
@onready var AudioMove : AudioStreamPlayer = Player.AudioSlimeMove if Player else null
@onready var AudioGroundsmash : AudioStreamPlayer = Player.AudioSlimeGroundsmash if Player else null

@onready var ShootBulletTimer : Timer = $ShootBulletTimer

@onready var BulletObject = preload("res://assets/Levels/bullets.tscn")# if enemy_type == 2 else null

@export var Enabled : bool = true

var OriginalPos = Vector2(0, 0)

var was_on_floor : bool = false
var was_on_wall : bool = false

var StatePlaying : bool = false

@export var Particles : bool = true

@onready var PrevGravityDirection : Global.GravityDirections = GravityDirection

@onready var _Position = self.position 

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
	if(_is_on_floor()): velocity.y = _jump_velocity * GravityDirection*Player.GlobalGravityDirection# * randf_range(1, 1.2)
#endregion

#region Player GroundSmash 
func _on_player_ground_smash_signal(player_instance : CharacterBody2D = Player) -> void:
	if(player_instance):
		if(Can_BeGroundSmash && _is_on_floor() && player_instance.GravityDirection == GravityDirection && global_position.distance_to(player_instance.position) <= Max_groundsmash_distance):
			_jump(JUMP_VELOCITY if enemy_type == 0 else SPECIAL_ENEMY_JUMP_VELOCITY)
			if(enemy_type == 0):
				LevelManager.AddStyle(0, "GroundSmash enemy")
				if(Particles): $HitParticles.emitting = true
				#Player.FrameFreeze(0.05, 0.4)
				velocity.x = Enemy_burst_speed if player_instance.position.x < position.x else Enemy_burst_speed*-1
				Move = false
				player_instance.Controller_Vibrate_Player_Movement(1)
				_groundsmash_player_sound()
#endregion

#region Player Slide 
func _on_player_slide_signal() -> void:
	if(_is_on_floor() && enemy_type == 0 && Player.GravityDirection == GravityDirection):
		LevelManager.AddStyle(0, "Slide enemy")
		if(Particles): $HitParticles.emitting = true
		#Player.FrameFreeze(0.05, 0.4)
		_jump(-400)
		Player.Camera.Shake(1.0, 5.0)
		velocity.x = Enemy_burst_speed if  Player.Sliding == Player.Sides.RIGHT else Enemy_burst_speed*-1
		Player.Controller_Vibrate_Player_Movement(1)
		Move = false
		_killed_by_player_sound()
#endregion

func _ready():
	if(RetroStyle):
		$Moveparticles.fixed_fps = 10
		$Moveparticles.interpolate = false
		$HitParticles.fixed_fps = 15
		$HitParticles.interpolate = false
		$HitFlyParticles.fixed_fps = 10
		$HitFlyParticles.interpolate = false
	if(SaveGame.get_config_value("Particles") != null):
		Particles = SaveGame.get_config_value("Particles")
	if(EnemyDirection == Directions.RIGHT): direction = 1
	elif(EnemyDirection == Directions.LEFT): direction = -1
	else: direction = 0
	if(ShootBulletTimer): ShootBulletTimer.wait_time = TimeToShoot
	if(Activate_on_color != Global.LASER_COLORS.NONE):
		Enabled = false
		Sprite.play("Laser")

var editable = preload("res://assets/Levels/Scripts/default_object.gd").new()
var Hovering : bool = false
@export var CanHover : bool = false

func _input(event):
	if(Edition.Is_in_editor && CanHover):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if(event.pressed && editable.Editor_Hover_Check(self.position.x, self.position.y, get_global_mouse_position())):
					$"../".Is_Hovering = true
					Hovering = true
				else:
					$"../".Is_Hovering = false
					Hovering = false

func _Enemie_Shoot_Sprite_Shader() -> void:
	Sprite.material.set_shader_parameter("progress", 1-(ShootBulletTimer.time_left/ShootBulletTimer.wait_time))

@export var grab_grid : float = 8.0
func _process(delta: float) -> void:
	if(RetroStyle):
		position = _Position
		position.x /= 8
		position.x = round(global_position.x)
		position.x *= 8
	if(Activate_on_color != Global.LASER_COLORS.NONE && SaveGame.get_player().LASERS_ENABLED[Activate_on_color]):
		Enabled = true
	
	if(Player.GlobalGravityDirection != PrevGravityDirection*GravityDirection):
		PrevGravityDirection = Player.GlobalGravityDirection * GravityDirection
		velocity.y = 100 * PrevGravityDirection*GravityDirection
	
	if(enemy_type == 2.0): _Enemie_Shoot_Sprite_Shader()
	if(Edition.Is_in_editor && Edition.Is_playing_in_editor != StatePlaying):
		OriginalPos = self.position
	if(Edition.Is_in_editor && CanHover && Hovering):
		if(Edition.IsErasingInEditor):
			self.queue_free()
		position = get_global_mouse_position()
		self.position.x = (floor(self.position.x/grab_grid)*grab_grid)+16.0
		self.position.y = (floor(self.position.y/grab_grid)*grab_grid)+10.0
	#region Physics
	if(Edition.Is_in_editor):
		if(Edition.Is_playing_in_editor):
			Enabled = true
		else:
			Enabled = false
			self.position = OriginalPos
			strech_size(1, 1)
			$Moveparticles.emitting = false
			$HitFlyParticles.emitting = false
	if(Enabled):
		#if(Player):
		if(Particles && _is_on_floor() && velocity.x > 0):
			$Moveparticles.emitting = true
		else:
			$Moveparticles.emitting = false
		if(Particles && !_is_on_floor() && enemy_type == 0):
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
				Sprite.play("Shoot")
		#endregion
		
		if(Player && Player.EnemiesPhysics):
			_update_sprite()
			
			if(is_on_wall() && !was_on_wall): direction *= -1
			
			#if(is_on_ceiling()): queue_free()
			
			if(velocity.y < 0): strech_size(0.7, 1.3)
			if(velocity.y >= MAX_FALL_SPEED): strech_size(0.5, 1.7)
			
			if(_is_on_floor() && was_on_floor == false): strech_size(1.7, 0.5)
			
			_strech_tick(delta)
			
			
			#region Trigger Player GroundSmash
			for child in get_parent().get_children():
				if child.is_in_group("Player") && !child.EnemyGroundSlamTimer.is_stopped(): 
					_on_player_ground_smash_signal(child)
			#endregion
			#region Gravity
			if (!_is_on_floor() &&  velocity.y < MAX_FALL_SPEED):
				velocity += get_gravity() * delta * GravityDirection*Player.GlobalGravityDirection
			#endregion
			if(direction): Sprite.flip_h = false if direction >= 0 else true
			Sprite.scale.y = abs(Sprite.scale.y)*GravityDirection*Player.GlobalGravityDirection
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
			was_on_floor = _is_on_floor()
			was_on_wall = is_on_wall()
			if(RetroStyle):
				var _pos = position
				position = _Position
				move_and_slide()
				_Position = position
				position = _pos
			else:
				move_and_slide()
	else:
		pass
#endregion

#region Scaling
@onready var original_scale = Sprite.scale
func strech_size(X, Y):
	Sprite.scale = Vector2(original_scale.x*X, original_scale.y*Y)
	Sprite.scale.y = abs(Sprite.scale.y)*GravityDirection*Player.GlobalGravityDirection

func _strech_tick(delta : float):
	Sprite.scale.x += (original_scale.x - Sprite.scale.x) * 15 * delta
	Sprite.scale.y += (original_scale.y*GravityDirection*Player.GlobalGravityDirection - Sprite.scale.y) * 15 * delta
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
	if(enemy_type == 0 && Particles):
		var DestroyParticles = preload("res://assets/Levels/Particles/destroy_enemy.tscn")
		var InstanceParticles = DestroyParticles.instantiate()
		get_tree().current_scene.add_child(InstanceParticles)
		InstanceParticles.position = self.position
		if(RetroStyle):
			InstanceParticles.RetroStyle()
	elif(enemy_type == 1 && Particles):
		var DestroyParticles = preload("res://assets/Levels/Particles/destroy_enemy_special.tscn")
		var InstanceParticles = DestroyParticles.instantiate()
		get_tree().current_scene.add_child(InstanceParticles)
		InstanceParticles.position = self.position
		if(RetroStyle):
			InstanceParticles.RetroStyle()
	#endregion
	self.queue_free()
#endregion

#Diferencia maxima para considerar que no se mueva
const dif_max_move = 0
func _update_sprite() -> void:
	#if Y mov > 0 then play Jump
	#If moving horizontally Walking
	#Else idle
	if(enemy_type != 2.0):
		if(velocity.y != 0): Sprite.play("Air")
		elif( abs(velocity.x-dif_max_move) > 0 && !is_on_wall() ): Sprite.play("Walking")
		else: Sprite.play("Idle")

func _is_on_floor() -> bool:
	if(GravityDirection*Player.GlobalGravityDirection == 1):
		return is_on_floor()
	else:
		return is_on_ceiling()
