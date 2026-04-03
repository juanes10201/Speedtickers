extends RichTextLabel

@onready var DespawnTimer = $DespawnTimer
@onready var OriginalY = self.position.y
@onready var GoToY = randf_range(20, 100)

func _process(delta: float) -> void:
	if(visible):
		self.position.y = lerp(self.position.y, OriginalY-GoToY, 4*delta)
		$AnimationPlayer.play("fade_out")
	

func _on_despawn_timer_timeout() -> void:
	visible = false
	self.position.y = OriginalY
	$AnimationPlayer.play("default")
	GoToY = randf_range(20, 60)
