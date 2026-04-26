extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Edition.Is_in_editor): show()
	else: hide()
	$CollisionShape2D.disabled = !Edition.Is_in_editor
	$CollisionShape2D2.disabled = !Edition.Is_in_editor
