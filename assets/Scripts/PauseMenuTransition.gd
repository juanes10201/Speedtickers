extends Sprite2D

@onready var Anim = $"AnimationPlayer" 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Anim.play("initial_movement")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!Anim.is_playing()):
		Anim.play("main_movement")
