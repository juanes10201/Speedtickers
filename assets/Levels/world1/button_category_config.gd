extends TextureButton 

@export var Category : Global.ConfigCategories = Global.ConfigCategories.audio

func _ready() -> void:
	#if(get_parent().Selected_Category == Category):
		#$AnimationPlayer.play("pressed")
		#$Border.play("selected")
		#return
	set_process(true)

func _process(delta: float) -> void:
	if(get_parent() && get_parent().Selected_Category != Category):
		$Border.play("unselected")
		

func _on_mouse_entered() -> void:
	if(get_parent().Selected_Category == Category):
		$AnimationPlayer.play("pressed")
		return
	$AnimationPlayer.play("initial_selected")
	#$Border.play("selected")

func _on_mouse_exited() -> void:
	$AnimationPlayer.play("unselected")

#func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if(anim_name == "initial_selected"):
		#$AnimationPlayer.play("selected")
		#$Border.play("selected")


func _on_pressed() -> void:
	$Border.play("selected")
	if(get_parent().Selected_Category == Category):
		$AnimationPlayer.play("pressed")
		return
	$AnimationPlayer.play("initial_pressed")
	get_parent().Selected_Category = Category
	print("Config Category is " + str(Category))
