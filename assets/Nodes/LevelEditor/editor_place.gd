extends Node2D

@export var SelectedTilemap : TileMapLayer
@export var EditorCursor : Node2D

@onready var LevelEditor = get_parent()

@export var SpriteFill1 : Sprite2D
@export var SpriteFill2 : Sprite2D

var LastCollidedBody : Node2D

func _convert_coordinates_to_local(pos : Vector2) -> Vector2i:
	var _pos_local = SelectedTilemap.to_local(pos)
	var tile_pos: Vector2i = SelectedTilemap.local_to_map(_pos_local)
	return tile_pos

func _place_tile_terrain_local_pos(pos : Vector2i):
	SelectedTilemap.set_cells_terrain_connect([pos], 2, 0)

func _place_tile_terrain_global_pos(pos : Vector2):
	var _pos_local = SelectedTilemap.to_local(pos)
	var tile_pos: Vector2i = SelectedTilemap.local_to_map(_pos_local)
	_place_tile_terrain_local_pos(tile_pos)

func _erase_tile_terrain_local_pos(pos : Vector2i):
	SelectedTilemap.set_cells_terrain_connect([pos], 2, -1)

func _erase_tile_terrain_global_pos(pos : Vector2i):
	var _pos_local = SelectedTilemap.to_local(pos)
	var tile_pos: Vector2i = SelectedTilemap.local_to_map(_pos_local)
	_erase_tile_terrain_local_pos(tile_pos)

var PreparingRectangle : bool = false
var PreparingRemoveRectangle : bool = false
var RectanglePos1 : Vector2 = Vector2(0.0, 0.0)
var RectanglePos2 : Vector2 = Vector2(0.0, 0.0)

func _fill_slope_global_tileset(pos1 : Vector2, pos2 : Vector2, RemoveTiles : bool = false) -> void:
	var _pos_local1 = SelectedTilemap.to_local(pos1)
	var tile_pos1: Vector2i = SelectedTilemap.local_to_map(_pos_local1)
	
	var _pos_local2 = SelectedTilemap.to_local(pos2)
	var tile_pos2: Vector2i = SelectedTilemap.local_to_map(_pos_local2)
	
	_fill_slope_local_tileset(tile_pos1, tile_pos2, RemoveTiles)

func _fill_slope_local_tileset(pos1 : Vector2, pos2 : Vector2, RemoveTiles : bool = false) -> void:
	var Cells : Array[Vector2i]
	#print("pos1: " + str(pos1))
	#print("pos2: " + str(pos2))
	for x in range(pos1.x, pos2.x):
		var _posY = pos1.y - tan(deg_to_rad(SlopeAngle))*abs(pos1.x - x)
		var Cell : Vector2i = Vector2i(x, _posY)
		Cells.append(Cell)
	#print(SelectedTilemap.tile_set.get_terrain_set_mode(3))
	if(!RemoveTiles):
		SelectedTilemap.set_cells_terrain_path(Cells, 2, 0)
	else:
		SelectedTilemap.set_cells_terrain_path(Cells, 3, -1)

func _fill_rectangle_global_tileset(pos1 : Vector2, pos2 : Vector2, RemoveTiles : bool = false) -> void:
	#Convertir las 2 posiciones a posiciones locales que entienda el tilemap
	var _pos_local1 = SelectedTilemap.to_local(pos1)
	var tile_pos1: Vector2i = SelectedTilemap.local_to_map(_pos_local1)
	
	var _pos_local2 = SelectedTilemap.to_local(pos2)
	var tile_pos2: Vector2i = SelectedTilemap.local_to_map(_pos_local2)
	
	_fill_rectangle_local_tileset(tile_pos1, tile_pos2, RemoveTiles)

func _fill_rectangle_local_tileset(pos1 : Vector2i, pos2 : Vector2i, RemoveTiles : bool = false) -> void:
	#Poner cada tile en la lista para luego enviarlo a pintar
	var Cells : Array[Vector2i]
	#var range1x = pos1.x if pos1.x < pos2.x else pos2.x
	#var range2x = pos1.x if pos1.x > pos2.x else pos2.x
	#var range1y = pos1.y if pos1.y < pos2.y else pos2.y
	#var range2y = pos1.y if pos1.y < pos2.y else pos2.y
	
	for x in range(pos1.x, pos2.x+1):
		for y in range(pos1.y, pos2.y+1):
			var Cell : Vector2i = Vector2i(x, y)
			Cells.append(Cell)
	if(!RemoveTiles):
		SelectedTilemap.set_cells_terrain_connect(Cells, 2, 0)
	else:
		SelectedTilemap.set_cells_terrain_connect(Cells, 2, -1)

#Angulo de la rampa
var SlopeAngle : float = 22.5

func _tick_tileset(delta: float):
	if(EditorCursor.SelectedSubNode == EditorCursor.TileTools.Pencil):
		if(Input.is_action_pressed("ui_editor_place") ):
			_place_tile_terrain_global_pos(get_global_mouse_position())
		elif(Input.is_action_pressed("ui_editor_erase") ):
			_erase_tile_terrain_global_pos(get_global_mouse_position())
	elif(EditorCursor.SelectedSubNode == EditorCursor.TileTools.Rectangle):
		#Visuales
		if(PreparingRectangle || PreparingRemoveRectangle):
			SpriteFill1.global_position = RectanglePos1
			SpriteFill2.global_position = EditorCursor.global_position
			SpriteFill1.show()
			SpriteFill2.show()
		
		#Iniciar forma de rectangulo
		if(Input.is_action_just_pressed("ui_editor_place") ):
			PreparingRectangle = true
			#Posicion 1 del rectangulo, la posicion 2 sera la final
			RectanglePos1 = EditorCursor.global_position
		#Al soltar crear el rectangulo
		elif(PreparingRectangle && !Input.is_action_pressed("ui_editor_place") ):
			RectanglePos2 = EditorCursor.global_position
			PreparingRectangle = false
			_fill_rectangle_global_tileset(RectanglePos1, RectanglePos2, false)
			SpriteFill1.hide()
			SpriteFill2.hide()
		
		#Lo mismo pero para eliminar
		if(Input.is_action_just_pressed("ui_editor_erase") ):
			PreparingRemoveRectangle = true
			#Posicion 1 del rectangulo, la posicion 2 sera la final
			RectanglePos1 = EditorCursor.global_position
		#Al soltar crear el rectangulo
		elif(PreparingRemoveRectangle && !Input.is_action_pressed("ui_editor_erase") ):
			RectanglePos2 = EditorCursor.global_position
			PreparingRemoveRectangle = false
			_fill_rectangle_global_tileset(RectanglePos1, RectanglePos2, true)
			SpriteFill1.hide()
			SpriteFill2.hide()
	elif(EditorCursor.SelectedSubNode == EditorCursor.TileTools.Slope):
		if(PreparingRectangle || PreparingRemoveRectangle):
			SpriteFill1.global_position = RectanglePos1
			SpriteFill2.global_position.x = EditorCursor.global_position.x
			SpriteFill2.global_position.y = SpriteFill1.global_position.y - tan(deg_to_rad(SlopeAngle))*abs(SpriteFill1.global_position.x - SpriteFill2.global_position.x)
			SpriteFill1.show()
			SpriteFill2.show()
		if(Input.is_action_just_pressed("ui_editor_place") ):
			PreparingRectangle = true
			#Posicion 1 del rectangulo, la posicion 2 sera la final
			RectanglePos1 = EditorCursor.global_position
		elif(PreparingRectangle && !Input.is_action_pressed("ui_editor_place") ):
			#RectanglePos2 = EditorCursor.global_position
			PreparingRectangle = false
			#print("Filling slope")
			_fill_slope_global_tileset(SpriteFill1.global_position, SpriteFill2.global_position, false)
			SpriteFill1.hide()
			SpriteFill2.hide()

func _tick_nodes(delta: float):
	if(Input.is_action_pressed("ui_editor_place")):
		if(CollidingBody):
			LastCollidedBody = CollidingBody
			ExpandingY = false
			ExpandingX = false
			ExpandingOriginalPos = Vector2(0.0,0.0)
			#Selecting a node
			SelectingBody = true
			CollidingBody.global_position = EditorCursor.global_position
		elif(ExpandYSelected):
			if(ExpandYSelected.is_in_group("Killbox")):
				ExpandYSelected.Sprite.material.set_shader_parameter("tile_size", ExpandYSelected.scale)
			ExpandingY = true
			ExpandYSelected.scale.y = ExpandingOriginalSize+abs(ExpandingOriginalPos.y-EditorCursor.global_position.y)/14
			#if(EditorCursor.OnGrid):
				#ExpandXSelected.scale.y = floor(ExpandXSelected.scale.y/EditorCursor.GridSizeSmall)*EditorCursor.GridSizeSmall
			if(!ExpandingOriginalPos):
				ExpandingOriginalPos = EditorCursor.global_position
		elif(ExpandXSelected):
			if(ExpandXSelected.is_in_group("Killbox")): ExpandXSelected.Sprite.material.set_shader_parameter("tile_size", ExpandXSelected.scale)
			ExpandingX = true
			ExpandXSelected.scale.x = ExpandingOriginalSize+abs(ExpandingOriginalPos.x-EditorCursor.global_position.x)/14
			#if(EditorCursor.OnGrid):
			#	ExpandXSelected.scale.x = floor(ExpandXSelected.scale.x/EditorCursor.GridSizeSmall)*EditorCursor.GridSizeSmall
			if(!ExpandingOriginalPos):
				ExpandingOriginalPos = EditorCursor.global_position
		#Create node
		elif(Input.is_action_just_pressed("ui_editor_place") && EditorCursor.SelectedNode != 9):
			ExpandingY = false
			ExpandingX = false
			ExpandingOriginalPos = Vector2(0.0,0.0)
			var NewNode = load(LevelEditor.SelectableObjects[EditorCursor.SelectedNode-1][EditorCursor.SelectedSubNode])
			var InstanceNode = NewNode.instantiate()
			LevelEditor.add_child(InstanceNode)
			InstanceNode.global_position = EditorCursor.global_position
	#Selecting Node
	elif(Input.is_action_pressed("ui_editor_erase") ):
		if(CollidingBody && !CollidingBody.is_in_group("Player") && !CollidingBody.is_in_group("YExpandEditor") && !CollidingBody.is_in_group("XExpandEditor")):
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
	#print(EditorCursor.SelectedNode)
	LevelEditor.IsTileMapSelected = (EditorCursor.SelectedNode == 0)
	#print(CollidingBody)
	if(LevelEditor.IsTileMapSelected): _tick_tileset(delta)
	else: _tick_nodes(delta)

var CollidingBody : Node2D = null
var SelectingBody : bool = false

func _on_editor_cursor_body_entered(body: Node2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		CollidingBody = body
		#LastCollidedBody = CollidingBody


func _on_editor_cursor_body_exited(body: Node2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		CollidingBody = null


func _on_editor_cursor_area_entered(area: Area2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		if(area.is_in_group("YExpandEditor")):
			ExpandYSelected = area.get_parent()
		if(area.is_in_group("XExpandEditor")):
			ExpandXSelected = area.get_parent()
		if(!area.is_in_group("XExpandEditor") && !area.is_in_group("YExpandEditor")):
			CollidingBody = area
			#LastCollidedBody = CollidingBody


func _on_editor_cursor_area_exited(area: Area2D) -> void:
	if(!SelectingBody && !ExpandingY && !ExpandingX):
		if(area.is_in_group("YExpandEditor")):
			ExpandYSelected = null
		if(area.is_in_group("XExpandEditor")):
			ExpandXSelected = null
		else: CollidingBody = null 
