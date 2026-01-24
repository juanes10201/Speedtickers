extends Area2D
@export var Text : RichTextLabel

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		Text.animate()
		if($Hologram && $Hologram.animation != "show"): $Hologram.play("show")


func _on_erase_text_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		Text.Animate = false
		Text.text = ""
		$Hologram.play("hide")
