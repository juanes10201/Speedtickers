extends AnimatedSprite2D
@export var NextTimer : Timer
@export var level_to_change = "level1"
@export var main_menu_scene = "res://assets/Nodes/Ui/main_menu_w_level_preview.tscn"
@export var menu_expo_scene = "main_menu_expo"
@export var ProgressB : ProgressBar
var progress : Array[float] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set fullscreen when on browser
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	self.play()
	ResourceLoader.load_threaded_request(main_menu_scene)
	$Anim.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(main_menu_scene, progress)
	var pct = progress[0] * 100
	ProgressB.value = pct
	if(ProgressB.value > 90.0 && !NextTimer.is_stopped()):
		ProgressB.value = 0.0
	if(NextTimer.is_stopped() && status == ResourceLoader.THREAD_LOAD_LOADED):
		var scene = ResourceLoader.load_threaded_get(main_menu_scene)
		get_tree().change_scene_to_file(main_menu_scene)
