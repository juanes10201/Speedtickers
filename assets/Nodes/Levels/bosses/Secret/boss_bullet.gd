extends Area2D

@onready var Player = SaveGame.get_player()

@export var Velocity : float = 100.0
@onready var Direction_to_go : Vector2 = Vector2(0.0, 0.0)

var Enabled : bool = false

func disable() -> void:
	Enabled = false

func enable() -> void:
	Enabled = true
	Direction_to_go = global_position.direction_to(Player.global_position)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = Enabled
	if(Enabled):
		global_position += Direction_to_go*Vector2(delta*Velocity, delta*Velocity)


func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Killbox")):
		disable()


func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")): Player.On_Death()
