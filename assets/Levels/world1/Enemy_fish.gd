extends Area2D
@export var Activate_on_color : Global.LASER_COLORS = Global.LASER_COLORS.NONE
@export var InitialMarker : Marker2D
@export var EndMarker : Marker2D
@export var Speed : float = 0.5
enum direction{
	INITIAL = 1,
	RETURN = -1
}
@export var CurrentDir = direction.INITIAL
@onready var Sprite = $Sprite 

@export var DifChangeDir : float = 20.0
@onready var CooldownDir = $CooldownDir

@export var WaterFloatLogic : Node2D

@onready var WaterTileset = SaveGame.get_group_node("WaterTileset")

@onready var Player : ClassPlayer = SaveGame.get_player()

var Enabled = true

func _set_rotation() -> void:
	var dir : Vector2 = EndMarker.global_position if CurrentDir == direction.INITIAL else InitialMarker.global_position
	look_at(dir)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(Activate_on_color != Global.LASER_COLORS.NONE):
		Enabled = false
	
	var tmp_global = InitialMarker.global_position
	InitialMarker.top_level = true
	InitialMarker.global_position = tmp_global
	
	tmp_global = EndMarker.global_position
	EndMarker.top_level = true
	EndMarker.global_position = tmp_global
	
	_set_rotation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!Enabled && Activate_on_color != Global.LASER_COLORS.NONE && Player.LASERS_ENABLED[Activate_on_color]):
		Enabled = true
	if(Enabled):
		var dir : Vector2 = EndMarker.global_position if CurrentDir == direction.INITIAL else InitialMarker.global_position
		dir.y = max(dir.y, WaterTileset.WaterLevel)
		WaterFloatLogic.float_logic(delta)
		global_position.x = lerpf(global_position.x, dir.x, Speed*delta)
		global_position.y = lerpf(global_position.y, dir.y, Speed*delta)
		print("dir: " + str(dir.y))
		print("water level: " + str(WaterTileset.WaterLevel))
		if(CooldownDir.is_stopped() && position.distance_to(dir) <= DifChangeDir):
			CurrentDir *= -1
			CooldownDir.start()
			_set_rotation()


func _on_body_entered(playerbody: Node2D) -> void:
	if(playerbody.is_in_group("Player")):
		if(playerbody.GroundSmash): return
		playerbody.On_Death()
