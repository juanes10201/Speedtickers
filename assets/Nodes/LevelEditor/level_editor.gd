extends Node2D

var IsTileMapSelected : bool = false
@export var Cursor : Node2D
@export var SelectableObjects : Array[String]
@export var TilesetLayers : Array[TileMapLayer]
@export var EditorCamera : Camera2D


func _ready() -> void:
	Edition.Is_in_editor = true
	
func _process(delta: float) -> void:
	pass
