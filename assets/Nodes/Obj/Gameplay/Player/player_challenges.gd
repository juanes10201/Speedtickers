extends Node2D

@onready var Player = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(Global.Selected_Challenge == Global.CHALLENGES.inverted_gravity):
		Player.GravityDirection = Global.GravityDirections.INVERTED
	elif(Global.Selected_Challenge == Global.CHALLENGES.speedrun):
		Player.CountTime = true
		var TimeLeft : Timer = $"../../Time_Left"
		if("SpeedrunWaitTime" in TimeLeft && TimeLeft.SpeedrunWaitTime != -1):
			TimeLeft.wait_time = TimeLeft.SpeedrunWaitTime
			TimeLeft.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
