extends Line2D

@export var Player : Node2D
var Activated : bool = false
@export var PointCooldown : Timer
var WasActivated : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(points)
	if(!Player):
		Player = SaveGame.get_player()
	if(Activated):
		hide()
		if(PointCooldown.is_stopped()):
			PointCooldown.start()
			add_point(Player.global_position)
		if(!WasActivated):
			clear_points()
	else:
		show()
	WasActivated = Activated
