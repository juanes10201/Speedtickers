extends Node2D

@export var EditorPlace : Node2D
@export var LevelEditor : Node2D

#Los datos se guardan todos en diccionarios y sub-diccionarios/sub-arrays ahi,
#todo lo que se guarda en json o archivo es un diccionario basicamente

#El formato es de la siguiente manera
#var Clipboard : Dictionary = {
#	"tiles":
#		[
#			vector2i[Z,Z]: [ZZZZZZZZZZZZZZZZ],
#			vector2i[Z,1]: [ZZZZZZZZZZZZZZZZ],
#			vector2i[Z,2]: [ZZZZZZZZZZZZZZZZ]
#			vector2i[1,Z]: [ZZZZZZZZZZZZZZZZ],
#			En este caso los chunks estarian en posicion [Z,Z], [1,Z], [2,Z], [Z,1]
#		], #los niveles se dividen en chunks de 8x8
#	"Nodes": {
#		"asset": "res://assets/Nodes/Obj/Gameplay/Enemie/enemie.tscn",
#		"EveryModifiedAtribute" : "example, value"
#	}
#}

#

var Clipboard : Dictionary = { Vector2i(0, 0): "AAAAAAAAAZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"}
const ChunkSize : int = 8
const ChunkDefaultValue : String = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"

@export var ParentOriginalNodes : Node2D
var OriginalNodesLoaded : Dictionary = {}

func GetSaveDataNodes(Nodes : Array) -> Array:
	print("Nodes: " + str(Nodes))
	var _result : Array = []
	for _node in Nodes:
		var _node_result : Dictionary = {}
		if(_node.has_meta(EditorPlace.NewNodeMetaNumber) && _node.has_meta(EditorPlace.NewNodeMetaSubNumber)):
			var _node_number = _node.get_meta(EditorPlace.NewNodeMetaNumber)
			var _node_subnumber = _node.get_meta(EditorPlace.NewNodeMetaSubNumber)
			print("node number: " + str(_node_number))
			print("node subnumber: " + str(_node_subnumber))
			
			var _original_scene_path = LevelEditor.SelectableObjects[_node_number][_node_subnumber]
			var _original_scene = null
			var DictionaryId : Vector2i = Vector2i(_node_number, _node_subnumber)
			_node_result["EditorId"] = DictionaryId
			if(DictionaryId in OriginalNodesLoaded):
				_original_scene = OriginalNodesLoaded[DictionaryId]
			else:
				_original_scene = GlobalFunctions.Create_node2d(_original_scene_path, ParentOriginalNodes) #_original_packed_scene.get_state()
				OriginalNodesLoaded[DictionaryId] = _original_scene
			
			var Properties : Dictionary = {}
			for property in _original_scene.get_property_list():
				var property_name = property.name
				var property_value = _original_scene.get(property_name)
				var changed_property_value = _node.get(property_name)
				if(property_name in _node && property_value != changed_property_value):
					if !(changed_property_value is Node):
						Properties[property_name] = changed_property_value
					#print("Value difference!: Name: " + str(property_name) + "; Value: " + str(property_value))
			_node_result["Properties"] = Properties
			_result.append(_node_result)
			#var MainNodeId = 0
			#for i in _original_scene_state.get_node_property_count(MainNodeId): #_original_scene_state.get_property_list():
			#	var _property_value = _original_scene_state.get_node_property_value(MainNodeId, i)
			#	var _property_name = _original_scene_state.get_node_property_name(MainNodeId, i)
			#	#if(property.name in _original_scene_state && _node.get(property.name) != _original_scene_state.get(property.name)):
			#	print("Property name: " + str(_property_name))
			#	print("Property value: " + str(_property_value))
			#print("!!!!!: " + str(_original_scene_state))
	OriginalNodesLoaded = {}
	for OriginalChild in ParentOriginalNodes.get_children():
		OriginalChild.queue_free()
	return _result

func GetSaveDataTiles(Tiles : Array, Tilemap : TileMapLayer, SaveData : Dictionary) -> Dictionary[Vector2i, String]:
	#var Current : int = 0
	var Saved : Dictionary[Vector2i, String] = { }
	#print(floor(-0.25))
	for Tile in Tiles:
		var Chunk : Vector2i = Vector2i(floor(float(Tile.x)/float(ChunkSize)), floor(float(Tile.y)/float(ChunkSize)) )
		#print("Chunk:" + str(Chunk))
		var ChunkPos : Vector2i = Vector2i( abs(Tile.x) % ChunkSize, abs(Tile.y) % ChunkSize )
		if(Tile.x < 0): ChunkPos.x = ChunkSize - ChunkPos.x
		if(Tile.y < 0): ChunkPos.y = ChunkSize - ChunkPos.y
		
		var ChunkIndex : int = abs(ChunkPos.x) + (abs(ChunkPos.y) * ChunkSize)
		
		#print("ChunkPos: " + str(ChunkPos))
		#Current += 1
		if(!Chunk in Saved): Saved[Chunk] = ChunkDefaultValue
		var tiledata : TileData = Tilemap.get_cell_tile_data(Tile)
		##El valor del autotile se guarda en hexabinario porque why not
		if(tiledata && ChunkIndex < Saved[Chunk].length() ):
			Saved[Chunk][ChunkIndex] = char(65+abs(tiledata.terrain))
	#print(Saved)
	print("Saved clipboard data")
	return Saved

const SaveLocation : String = "res://assets/Saved/LevelEditor/"

func SaveTilesToFile(FileName : String, Nodes : Array, Tiles : Array, Tilemap : TileMapLayer, SaveData : Dictionary) -> void:
	var SavedTileset = GetSaveDataTiles(Tiles, Tilemap, SaveData)
	var SavedNodes = GetSaveDataNodes(Nodes)
	var Saved : Dictionary = {
		"Tileset" = SavedTileset,
		"Nodes" = SavedNodes
	}
	SaveGame.SaveJsonFile(SaveLocation + FileName, Saved)
	print("Saved!")

func SaveDataTileToClipboard(Tiles : Array, Tilemap : TileMapLayer, SaveData : Dictionary) -> void:
	Clipboard = GetSaveDataTiles(Tiles, Tilemap, SaveData)

func LoadDataTiles(Tilemap : TileMapLayer, SaveData : Dictionary) -> void:
	for Chunk in SaveData:
		for Index in range(0, SaveData[Chunk].length()):
			var Pos : Vector2i = Vector2i(Chunk.x*ChunkSize+ Index%ChunkSize, Chunk.y*ChunkSize+ Index/ChunkSize)
			#print(Pos)
			if(SaveData[Chunk][Index] == 'Z'):
				EditorPlace._erase_tile_terrain_local_pos(Pos)
			else:
				var SubTile : int = SaveData[Chunk][Index].unicode_at(0) - 65
				#print(SubTile)
				EditorPlace._place_tile_terrain_local_pos(Pos, EditorPlace.SelectedTilemap, SubTile)
