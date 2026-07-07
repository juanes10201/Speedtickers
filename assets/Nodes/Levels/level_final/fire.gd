extends Area2D

@export var MaxVelocity : float = 400.0
@export var Acc : float = 30.0
var Velocity : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Velocity += Acc
	if(Velocity > MaxVelocity): Velocity = MaxVelocity
	position.x += Velocity*delta
