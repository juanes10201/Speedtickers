extends Node2D

@onready var Particle1 = $Particle1
@onready var Particle2 = $Particle2
@onready var Particle3 = $Particle3
@onready var Particle4 = $Particle4
@onready var Particle5 = $Particle5

func RetroStyle() -> void:
	Particle1.fixed_fps = 10
	Particle1.interpolate = false
	Particle2.fixed_fps = 10
	Particle2.interpolate = false
	Particle3.fixed_fps = 10
	Particle3.interpolate = false
	Particle4.fixed_fps = 10
	Particle4.interpolate = false
	Particle5.fixed_fps = 10
	Particle5.interpolate = false

func _ready() -> void:
	Particle1.emitting = true
	Particle2.emitting = true
	Particle3.emitting = true
	Particle4.emitting = true
	Particle5.emitting = true
