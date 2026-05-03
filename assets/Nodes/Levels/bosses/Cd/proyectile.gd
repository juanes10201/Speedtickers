extends Area2D

var velocity : Vector2 = Vector2(0.0, 0.0)
const acc : float = 5.0
const lerp_acc : float = 2.0
const max_vel : Vector2 = Vector2(100.0, 100.0) 

@onready var OriginalPos : Vector2 = global_position
@export var TimerInitialFly : Timer
@onready var Player = SaveGame.get_player()
@export var Boss : Node2D
var GoToPos : Vector2 = Vector2(0.0, 0.0)

var initial_dir : float = 0.0

var TweenMove : Tween = null

func _ready() -> void:
	TimerInitialFly.start()
	initial_dir = ceil(clamp(Player.global_position.x-global_position.x, -1.0, 1.0))
	_set_enabled(false)

func _set_enabled(state : bool) -> void:
	visible = state
	$Sprite2D.visible = state
	monitoring = state
	$CollisionShape2D.disabled = !state

func _explode() -> void:
	_set_enabled(false)

func restart() -> void:
	global_position = Boss.global_position
	TimerInitialFly.start()
	_set_enabled(true)
	velocity = Vector2(0.0, 0.0)
	OriginalPos = global_position
	TweenMove = null

func _process(delta: float) -> void:
	#if(velocity.x <= max_vel.x): velocity.x += acc
	
	if(!TweenMove && TimerInitialFly.is_stopped()):
		TweenMove = get_tree().create_tween()
		TweenMove.set_trans(Tween.TRANS_QUAD)
		TweenMove.set_ease(Tween.EASE_IN_OUT)
		TweenMove.tween_property(self, "global_position", GoToPos, 0.7)
		TweenMove.tween_callback(self._explode)
		#position.x = lerpf(position.x, GoToPos.x, lerp_acc*delta)
		#position.y = lerpf(position.y, GoToPos.y, lerp_acc*delta)
	else:
		velocity.y -= acc*delta
		velocity.x += acc/2*initial_dir*delta
		position += velocity
	#print(position)


func _on_timer_initial_fly_timeout() -> void:
	GoToPos = Player.global_position
