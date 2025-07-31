extends Area2D

@export var current_level : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)


var editable = preload("res://assets/Levels/Scripts/default_object.gd").new()
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
	if(body.is_in_group("Player") && !body.Dead):
		#region Save level
		SaveGame.savelevelrecord(current_level ,$"../Time_Left".wait_time - $"../Time_Left".time_left)
		#endregion
		#region Change level
		var _scene_string : String = "res://assets/Levels/world1/level" + str(current_level+1) + ".tscn"
		print(_scene_string)
		get_tree().change_scene_to_file(_scene_string)
		#endregion
