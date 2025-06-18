extends Sprite2D

@onready var Player = $"../../Player"

func _ready():
	if(Player && !Player.PlayedBefore && !Edition.DoneIntro):
		Edition.DoneIntro = true
		$AnimationPlayer.play("Start")
