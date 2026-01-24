extends CharacterBody2D

enum Directions{
	Go = 1,
	Return = -1,
	none = 0
}
var Direction = Directions.Go
@export var SPEED = 50.0
const JUMP_VELOCITY = -400.0
@export var AccX : float = 30.0
@export var PointTo : Marker2D
@onready var InitialX : float = self.position.x
@onready var GoToX : float = PointTo.position.x if PointTo else 0.0

func _physics_process(delta: float) -> void:
	$Sprite.scale.x = abs($Sprite.scale.x) if self.global_position.x-GoToX > 0 else abs($Sprite.scale.x)*-1
	if not is_on_floor():
		velocity += get_gravity() * delta
	if(PointTo):
		if(Direction == Directions.Go): GoToX = PointTo.position.x
		elif(Direction == Directions.Return): GoToX = InitialX
		if(abs(GoToX - self.global_position.x) < 60):
			velocity.x = lerp(velocity.x, 0.0, 5*delta)
			if(abs(velocity.x) < 0.1): Direction *= -1
		elif(GoToX <= self.global_position.x):
			if(abs(velocity.x) < SPEED):
				velocity.x -= AccX*delta
		elif(GoToX >= self.global_position.x):
			if(abs(velocity.x) < SPEED):
				velocity.x += AccX*delta

	move_and_slide()
