extends Area2D

@export var BossBulletGenerator : Node
@export var BossBulletCooldownTimer : Timer
@export var AnimPlayer : AnimationPlayer

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
	if(CurrentAttack == BossAttacks.PaintCircle && BossBulletCooldownTimer.is_stopped()):
		AnimPlayer.play("Attack_paint_circle")
		BossBulletGenerator.generate_bullet(1)
		BossBulletCooldownTimer.start()
