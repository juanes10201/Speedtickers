extends WorldEnvironment

@onready var CRT = $CanvasLayer/ColorRect3

func _ready() -> void:
	#Set the shader params to the actual resolution of the game
	var Res : Vector2 = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	#Res.x += 500
	#Res.y += 500
	CRT.material.set_shader_parameter("resolution", Res)
	if(Edition.CrtFilter): CRT.show()
	else: CRT.hide()
