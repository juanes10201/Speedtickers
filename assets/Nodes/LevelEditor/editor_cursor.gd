extends Area2D

@onready var LevelEditor = get_parent()
@export var EditorPlace : Node2D

#0: Tileset
#>= 1, any other loaded node
var SelectedNode : int = 0

#var OnGrid : bool = true
var GridSize : int = 16

#La idea es que haya 2 posibles comportamientos
#Uno que funciona en base a un grid 16x16 que seria los de los diferentes tilemaps
#Y el otro consiste en importar diferentes objetos tscn, los cuales pueden ser movidos por el cursor
#y ademas cambiados sus valores @export

func _tick_position(delta: float):
	#Grid position
	if(LevelEditor.IsTileMapSelected): position = floor(get_global_mouse_position()/GridSize)*GridSize
	else: position = get_global_mouse_position()

func _change_selected_node_next() -> void:
	SelectedNode += 1
	if(SelectedNode > LevelEditor.SelectableObjects.size()):
		SelectedNode = 0

func _change_selected_node_prev() -> void:
	SelectedNode -= 1
	if(SelectedNode < 0):
		SelectedNode = LevelEditor.SelectableObjects.size()

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(EditorPlace.CollidingBody):
		$Sprite.play("Select")
	elif(EditorPlace.ExpandYSelected):
		$Sprite.play("SizeY")
	elif(EditorPlace.ExpandXSelected):
		$Sprite.play("SizeX")
	else: $Sprite.play(str(SelectedNode))
	if(Input.is_action_pressed("editor_element1")): SelectedNode = 0
	if(Input.is_action_pressed("editor_element2")): SelectedNode = 1
	if(Input.is_action_pressed("editor_element3")): SelectedNode = 2
	if(Input.is_action_pressed("editor_element4")): SelectedNode = 3
	if(Input.is_action_pressed("editor_element5")): SelectedNode = 4
	if(Input.is_action_pressed("editor_element6")): SelectedNode = 5
	if(Input.is_action_pressed("editor_element7")): SelectedNode = 6
	if(Input.is_action_pressed("editor_element8")): SelectedNode = 7
	if(Input.is_action_pressed("editor_element9")): SelectedNode = 8
	if(Input.is_action_pressed("editor_element10")): SelectedNode = 9
	_tick_position(delta)
