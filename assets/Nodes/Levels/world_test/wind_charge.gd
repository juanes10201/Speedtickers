@tool
extends Line2D

@export var Speed : float = 150.0
@export var GlobalSpeed : float = 0.0
@export var Activate_on_color : Global.LASER_COLORS = Global.LASER_COLORS.NONE
@export var Enabled : bool = true
@export var CooldownTime : float

@export var Closed : bool = true

@export var Path : Path2D
@export var MovOffset : Vector2 = Vector2(0.0, -5.0)
@export var EndWithSlam : bool = false
@export var RailedNodes : Node

@onready var Player = SaveGame.get_player()

func _reload() -> void:
	Path.global_position = self.global_position
	Path.curve.clear_points()
	for point in points:
		Path.curve.add_point(point)
	Path.curve.add_point(points[0])

func _ready() -> void:
	if(Activate_on_color != Global.LASER_COLORS.NONE): Enabled = false
	_reload()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		for i in range(points.size()):
			var pos : Vector2 = Path.curve.get_point_position(i)
			if !pos or pos not in points:
				print("Reloading Wind Sand")
				_reload()
	else:
		if(Activate_on_color != Global.LASER_COLORS.NONE && Player.LASERS_ENABLED[Activate_on_color]):
			for PathFollow in Path.get_children():
				if(PathFollow is PathFollow2D):
					PathFollow.restart()
