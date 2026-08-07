extends StaticBody2D

@onready var Sprite = $Sprite
@onready var Player = SaveGame.get_player()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Sprite.self_modulate.a = 0.9


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!Player): Player = SaveGame.get_player()
	if(Player.HaveKey):
		Sprite.self_modulate.a = lerpf(Sprite.self_modulate.a, 0.3, 15*delta)
		$CollisionShape2D.disabled = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass
