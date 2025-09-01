extends Node2D

@onready var Raycast = $"ShadowRaycast"
@onready var RaycastInvertedGravity = $"ShadowRaycastInvertedGravity"

@onready var Sprite = $"ShadowSprite"

#Raycast used depends if the player is in normal or inverted gravity
func _test_raycast() -> bool:
	if(!get_parent()._is_on_floor()):
		if(get_parent().GravityDirection == Global.GravityDirections.INVERTED):
			Raycast.enabled = false
			RaycastInvertedGravity.enabled = true
			if(RaycastInvertedGravity.is_colliding()): return true
			else: return false
		else:
			Raycast.enabled = true
			RaycastInvertedGravity.enabled = false
			if(Raycast.is_colliding()): return true
			else: return false
	return false

func _process(delta: float) -> void:
	if(_test_raycast()):
		Sprite.show()
		if(get_parent().GravityDirection == Global.GravityDirections.MAIN):
			Sprite.position = Raycast.get_collision_point()
		else:
			Sprite.position = RaycastInvertedGravity.get_collision_point()
	else:
		Sprite.hide()
