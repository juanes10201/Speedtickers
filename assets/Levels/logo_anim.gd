extends Sprite2D

@onready var Player = $"../../Player"

func _ready():
	if(Player && !Player.PlayedBefore):
		$AnimationPlayer.play("Start")
