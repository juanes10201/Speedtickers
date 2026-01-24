extends AnimatedSprite2D
@onready var player = SaveGame.get_player()

func _process(delta: float) -> void:
	self.scale.x = abs(self.scale.x) if player.global_position > self.global_position else abs(self.scale.x)*-1 
