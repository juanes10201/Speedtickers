extends Node2D

@export var SelectedTilemap : TileMapLayer
@export var EditorCursor : Node2D

@onready var LevelEditor = get_parent()

func _place_tile_terrain_local_pos(pos : Vector2i):
	SelectedTilemap.set_cells_terrain_connect([pos], 2, 0)

func _place_tile_terrain_global_pos(pos : Vector2):
	var _pos_local = SelectedTilemap.to_local(pos)
	var tile_pos: Vector2i = SelectedTilemap.local_to_map(_pos_local)
	_place_tile_terrain_local_pos(tile_pos)

func _erase_tile_terrain_local_pos(pos : Vector2i):
	SelectedTilemap.set_cell(pos, -1)#1, Vector2i(0, 0))

func _erase_tile_terrain_global_pos(pos : Vector2i):
	var _pos_local = SelectedTilemap.to_local(pos)
	var tile_pos: Vector2i = SelectedTilemap.local_to_map(_pos_local)
	_erase_tile_terrain_local_pos(tile_pos)

func _tick_tileset(delta: float):
	if(Input.is_action_pressed("ui_editor_place") ):
		_place_tile_terrain_global_pos(get_global_mouse_position())
	elif(Input.is_action_pressed("ui_editor_erase") ):
		_erase_tile_terrain_global_pos(get_global_mouse_position())

func _tick_nodes(delta: float):
	if(Input.is_action_pressed("ui_editor_place")):
		if(CollidingBody):
			ExpandingY = false
			ExpandingX = false
			ExpandingOriginalPos = Vector2(0.0,0.0)
			#Selecting a node
			SelectingBody = true
			CollidingBody.global_position = EditorCursor.global_position
		elif(ExpandYSelected):
			ExpandingY = true
			ExpandYSelected.scale.y = ExpandingOriginalSize+abs(ExpandingOriginalPos.y-EditorCursor.global_position.y)/14
			if(!ExpandingOriginalPos):
				ExpandingOriginalPos = EditorCursor.global_position
		elif(ExpandXSelected):
			ExpandingX = true
			ExpandXSelected.scale.x = ExpandingOriginalSize+abs(ExpandingOriginalPos.x-EditorCursor.global_position.x)/14
			if(!ExpandingOriginalPos):
				ExpandingOriginalPos = EditorCursor.global_position
		#Create node
		elif(Input.is_action_just_pressed("ui_editor_place")):
			ExpandingY = false
			ExpandingX = false
			ExpandingOriginalPos = Vector2(0.0,0.0)
			var NewNode = load(LevelEditor.SelectableObjects[EditorCursor.SelectedNode-1])
			var InstanceNode = NewNode.instantiate()
			LevelEditor.add_child(InstanceNode)
			InstanceNode.global_position = EditorCursor.global_position
	#Selecting Node
	elif(Input.is_action_pressed("ui_editor_erase") ):
		if(CollidingBody && !CollidingBody.is_in_group("YExpandEditor") && !CollidingBody.is_in_group("XExpandEditor")):
			CollidingBody.queue_free()
	elif(CollidingBody):
		SelectingBody = false
	if(!Input.is_action_pressed("ui_editor_place") && ExpandingY):
		#print("yes")
		ExpandingY = false
		ExpandYSelected = null
		ExpandingOriginalPos = Vector2(0.0,0.0)
	if(!Input.is_action_pressed("ui_editor_place") && ExpandingX):
		ExpandingX = false
		ExpandXSelected = null
		ExpandingOriginalPos = Vector2(0.0,0.0)
	#print("Expanding y: " + str(ExpandYSelected))
	#print("Expanding X: " + str(ExpandXSelected))
	#print("SelectingBody: " + str(SelectingBody))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var ExpandingY : bool = false
var ExpandYSelected : Node2D = null
var ExpandingX : bool = false
var ExpandXSelected : Node2D = null
var ExpandingOriginalPos : Vector2 = Vector2(0.0, 0.0)
var ExpandingOriginalSize : float = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	LevelEditor.IsTileMapSelected = (EditorCursor.SelectedNode == 0)
	#print(CollidingBody)
	if(LevelEditor.IsTileMapSelected): _tick_tileset(delta)
	else: _tick_nodes(delta)

var CollidingBody : Node2D = null
var SelectingBody : bool = false

func _on_editor_cursor_body_entered(body: Node2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		CollidingBody = body


func _on_editor_cursor_body_exited(body: Node2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		CollidingBody = null


func _on_editor_cursor_area_entered(area: Area2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		if(area.is_in_group("YExpandEditor")):
			ExpandYSelected = area.get_parent()
		if(area.is_in_group("XExpandEditor")):
			ExpandXSelected = area.get_parent()
		if(!area.is_in_group("XExpandEditor") && !area.is_in_group("YExpandEditor")): CollidingBody = area


func _on_editor_cursor_area_exited(area: Area2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		if(area.is_in_group("YExpandEditor")):
			ExpandYSelected = null
		if(area.is_in_group("XExpandEditor")):
			ExpandXSelected = null
		else: CollidingBody = null 
