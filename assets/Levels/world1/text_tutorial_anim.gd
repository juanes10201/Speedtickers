extends RichTextLabel

@export var Animate : bool = false
@onready var OgText : String = text 
@export var TextDelay : Timer
@export var Voice : AudioStreamPlayer

func _ready() -> void:
	text = ""

func animate() -> void:
	Animate = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Animate && text != OgText && TextDelay.is_stopped()):
		text = text + OgText[text.length()]
		TextDelay.start()
		if(text[text.length()-1] != ' '):
			Voice.stop()
			Voice.pitch_scale = randf_range(.9, 1.1)
			Voice.play()
