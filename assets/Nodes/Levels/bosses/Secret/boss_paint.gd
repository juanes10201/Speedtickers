extends Node2D

@export var BossBulletGenerator : Node
@export var BossBulletCooldownTimer : Timer
@export var AnimPlayer : AnimationPlayer

@export var Hand1 : Area2D
@export var Hand2 : Area2D

@export var BossHitCooldownTimer : Timer

enum BossAttacks{
	PaintCircle = 0,
	ThrowPaint = 1,
	RegenerateStage = 2,
	EscapeStage = 3
}
var CurrentAttack = BossAttacks.PaintCircle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(CurrentAttack == BossAttacks.PaintCircle && BossBulletCooldownTimer.is_stopped() && BossHitCooldownTimer.is_stopped()):
		AnimPlayer.play("Attack_paint_circle")
		BossBulletGenerator.generate_bullet(1, Hand1.global_position)
		BossBulletCooldownTimer.start()
	if(!BossHitCooldownTimer.is_stopped()):
		AnimPlayer.speed_scale = 5.0
	else:
		AnimPlayer.speed_scale = 1.0

func _on_hand_1_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		Hand1.damage(10)

func _on_hand_2_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		Hand2.damage(10)
