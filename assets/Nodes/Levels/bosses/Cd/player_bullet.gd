extends Area2D

var Enabled : bool = false
var dir : int = 0
const speed : float = 800.0

func shoot(d : int, pos : Vector2) -> void:
	Enabled = true
	dir = d
	$Sprite2D2.show()
	show()
	global_position = pos

func _ready() -> void:
	pass # Replace with function body.

func disable() -> void:
	$Sprite2D2.hide()
	hide()
	Enabled = false

func _process(delta: float) -> void:
	if(Enabled):
		position.x += speed*delta*dir


func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")): return
	disable()
