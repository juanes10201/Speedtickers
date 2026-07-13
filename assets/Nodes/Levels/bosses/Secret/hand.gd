extends Area2D

var Life : int = 100
@onready var Player = SaveGame.get_player()
@export var CooldownHitTimer : Timer

func damage(amount : int = 1) -> void:
	Life -= amount
	Player.kicked_boss(ceil(clamp(Player.global_position.x-global_position.x, -1.0, 1.0)))
	CooldownHitTimer.start()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$RichTextLabel.text = str(Life)
