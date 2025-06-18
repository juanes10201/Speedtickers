extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#get_parent().disable_collision()
	pass

func _on_body_entered(body: Node2D):
 	#Trigger gameover if touches Player	
	if (body.is_in_group("Player")):
		if(get_parent().enemy_type == 0 && get_parent().check_collision()): get_parent().disable_collision()
		if(body.Slide && get_parent().enemy_type == 0): get_parent()._on_player_slide_signal()
		else: body.On_Death()
	else:
		if(!get_parent().check_collision()): get_parent().enable_collision()
