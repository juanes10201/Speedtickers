extends Node2D

@export var FloatOnWater : bool = true
@export var FallWhenNoWater : bool = true 
@export var OnWaterRay : RayCast2D
@export var NotOnWaterRay : RayCast2D
@export var AddLinearVelocity : bool = false
@export var VelJumpWater : float = -300.0
@export var AccEscapeWater : float = -5.0
@export var Enabled = true

@onready var WaterTileset = SaveGame.get_group_node("WaterTileset")

var constant_linear_velocity : Vector2 = Vector2(0.0,0.0)
var Velocity : Vector2 = Vector2(0.0, 0.0)

@export var FallBelowWaterLevel : bool = true

@onready var Parent = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func float_logic(delta: float) -> void:
	if(Enabled):
		#region Float On Water
		OnWaterRay.enabled = true
		if(FloatOnWater && OnWaterRay.is_colliding() && Parent.position.y >= WaterTileset.WaterLevel):
			constant_linear_velocity.y = VelJumpWater
			Velocity.y += AccEscapeWater
			Parent.position.y += delta*Velocity.y
		else:
			constant_linear_velocity.y = 0.0
			#region Gravity
			if(!NotOnWaterRay.is_colliding() || NotOnWaterRay.global_position.y+NotOnWaterRay.target_position.y < WaterTileset.WaterLevel):
				if(FallWhenNoWater && (FallBelowWaterLevel || Parent.global_position.y < WaterTileset.WaterLevel) ):
					if(NotOnWaterRay.get_collider() is TileMapLayer):
						return
					Velocity.y -= AccEscapeWater
					Parent.position.y += delta*Velocity.y
			#endregion
			else:
				Velocity.y = 0.0
		#endregion
		if(constant_linear_velocity && AddLinearVelocity):
			Parent.constant_linear_velocity = constant_linear_velocity
	else:
		OnWaterRay.enabled = false
		Velocity.y = 0.0
