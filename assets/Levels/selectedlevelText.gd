extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#region current level
	var Flag = $"../../Flag"
	if(Flag):
		var scene_name = Flag.current_level
		text = "[center]" + str(scene_name) + "[/center]"
		print("Currently in level: " + str(scene_name))
	#endregion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
