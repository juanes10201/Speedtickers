extends Area2D

@export var BSide : bool = false
@export var Gb : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	if($PointLight2D): $PointLight2D.show()


var editable = preload("res://assets/Scripts/default_object.gd").new()
var Hovering : bool = false
@export var CanHover : bool = false

func _input(event):
	if(Edition.Is_in_editor && CanHover):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if(event.pressed && editable.Editor_Hover_Check(self.position.x, self.position.y, get_global_mouse_position())):
					$"../".Is_Hovering = true
					Hovering = true
				else:
					$"../".Is_Hovering = false
					Hovering = false

@export var grab_grid : float = 8.0
func _process(delta: float) -> void:
	if(Edition.Is_in_editor && CanHover && Hovering):
		if(Edition.IsErasingInEditor):
			self.queue_free()
		position = get_global_mouse_position()
		self.position.x = (floor(self.position.x/grab_grid)*grab_grid)+16.0
		self.position.y = (floor(self.position.y/grab_grid)*grab_grid)+10.0

func _on_body_entered(body):
	if(body.is_in_group("Player") && !body.Dead && body.ReplayAction == Global.ReplayStates.STOPPED):
		var StyleRatio : float = 1.0
		if(LevelManager.get_level_time()):
			StyleRatio = LevelManager.get_level_time().time_left/LevelManager.get_level_time().wait_time
		#print(StyleRatio)
		LevelManager.AddStyle(3, "Finished level", 1/3+StyleRatio*2/3)
		body._play_sound(SongPlayer.AudioCompleteLevel, true, true, 1, 1, .9, 0.0, 1.2)
		var _lvl = LevelManager.get_level()
		if(_lvl <= 0): _lvl = 0
		#region Save level
		SaveGame.SaveLevelRecord(_lvl ,$"../Time_Left".wait_time - $"../Time_Left".time_left)
		#endregion
		#region Change level
		LevelManager.change_to_level(_lvl+1, BSide, Gb)
		#endregion
