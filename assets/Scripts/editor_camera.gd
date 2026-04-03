extends Camera2D

var ShakeRangeStrenght : float = 30.0
var ShakeFade : float = 5.0
var ShakeStrenght : float = 0.0

var rng = RandomNumberGenerator.new()

@export var EditorMoveSpeed : float = 200
@export var EditorDragSpeed : float = 1

enum Cinematic_types{
	FOLLOW_PLAYER,
	CREDITS,
	EDITOR
}
#@export var Cinematic_type : Cinematic_types = Cinematic_types.FOLLOW_PLAYER
#@onready var credits_ystart = position.y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#if(Cinematic_type == Cinematic_types.CREDITS): self.position.y -= 250


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_pressed("ui_up")):
		position.y -= EditorMoveSpeed * delta
	elif(Input.is_action_pressed("ui_down")):
		position.y += EditorMoveSpeed * delta
	if(Input.is_action_pressed("ui_right")):
		position.x += EditorMoveSpeed * delta
	if(Input.is_action_pressed("ui_left")):
		position.x -= EditorMoveSpeed * delta
	#position = sin(position.x, position.y)
	
	TickShake(delta)
	#if(Cinematic_type == Cinematic_types.CREDITS): self.position.y = lerpf(self.position.y, credits_ystart, 2*delta)

#region Camera Shake
func Shake(_shakerangestrenght, _shakefade) -> void:
	ShakeRangeStrenght = _shakerangestrenght
	ShakeFade = _shakefade
	ShakeStrenght = ShakeRangeStrenght

func TickShake(delta) -> void:
	if(ShakeStrenght > 0):
		ShakeStrenght = lerpf(ShakeStrenght, 0, ShakeFade * delta)
		offset = ApplyShake()
func ApplyShake() -> Vector2:
	return Vector2(rng.randf_range(-ShakeStrenght, ShakeStrenght), rng.randf_range(-ShakeStrenght, ShakeStrenght))
#endregion
