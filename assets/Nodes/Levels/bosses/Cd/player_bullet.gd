extends Area2D

var Enabled : bool = false
var dir : int = 0
const speed : float = 800.0
var difXmult : float = 7

func shoot(d : int, pos : Vector2, ShootMoveXNum : int) -> void:
	Enabled = true
	dir = d
	$Sprite2D2.show()
	show()
	global_position = pos
	position.y -= difXmult*ShootMoveXNum-2

func _ready() -> void:
	pass # Replace with function body.

func disable() -> void:
	$Sprite2D2.hide()
	hide()
	Enabled = false

func _process(delta: float) -> void:
	if(Enabled):
		position.x += speed*delta*dir

func remove_boss_life(boss : Node2D, amount : int) -> void:
	if(boss.ShieldLife > 0): boss.ShieldLife -= amount
	else: boss.BossLife -= amount

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("CdBoss")): remove_boss_life(body, 1)
	if(body.is_in_group("Player")): return
	disable()


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
