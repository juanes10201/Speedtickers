extends PathFollow2D

@export var Line : Line2D
@export var CooldownAnim : bool = true

@export var CooldownTimer : Timer
@onready var OriginalRatio : float = progress_ratio

@onready var previous_ratio : float = progress_ratio

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if(Line.Enabled):
	restart()

func restart() -> void:
	if(progress_ratio >= OriginalRatio):
		if(CooldownTimer): CooldownTimer.start()
		progress_ratio = OriginalRatio
		previous_ratio = progress_ratio

func _reload_material_shader() -> void:
	for Child in get_children():
		if(!CooldownTimer.is_stopped() && Child is RigidBody2D):
			Child.material.set_shader_parameter("progress", 1-(CooldownTimer.time_left/CooldownTimer.wait_time) )

func _process(delta: float) -> void:
	if(Line.Enabled && CooldownTimer.is_stopped()): progress += Line.Speed * delta
	_reload_material_shader()
	if(previous_ratio > progress_ratio):
		_restart()
	else:
		previous_ratio = progress_ratio
	print(OriginalRatio)
