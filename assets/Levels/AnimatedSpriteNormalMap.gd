extends Node2D

var flip_h : bool

func _ready() -> void:
	$Anim.play("Idle")

func _process(delta: float) -> void:
	for Child in get_children():
		if(Child.get_class() == "Sprite2D"):
			Child.flip_h = flip_h

func play(Anim : String):
	$Anim.play(Anim)
