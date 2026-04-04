extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if(Global.get_level()+1 < 10):
	#	position.x = 25
	#region current level
	print("Current level: " + str(Global.get_level()+1))
	text = str(Global.get_level()+1)
	#endregion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Edition.Is_in_editor):
		hide()
		$"../Sprite2D".hide()
	if(int(text) < 0):
		hide()
		text = "1"
