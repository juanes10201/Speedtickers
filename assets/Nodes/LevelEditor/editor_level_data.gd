extends Node2D

@export var LevelEditor : Node2D
var ExportedLevel : bool = false

func set_owner_recursive(node: Node, owner: Node):
	for child in node.get_children():
		child.set_owner(node)
		for child2 in child.get_children():
			if(child2 is Camera2D):
				child2.set_owner(owner)

func save_level_data():
	print("Saving level...")
	ExportedLevel = true
	
	#Edition.Is_in_editor = false
	#Edition.Is_playing_in_editor = false
	
	LevelEditor._play_state_tick(true)
	
	var saved_map = self.duplicate()
	set_owner_recursive(saved_map, saved_map)
	# Continue to save
	var save  = PackedScene.new()
	save.pack(saved_map)
	ResourceSaver.save(save, "res://assets/Nodes/LevelEditor/Saved//level1.tscn")
	
	LevelEditor._play_state_tick(false)
	
	#Reset to editor state
	Edition.Is_in_editor = true
	Edition.Is_playing_in_editor = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if(Input.is_action_just_pressed("ui_editor_save")): save_level_data()
	pass
