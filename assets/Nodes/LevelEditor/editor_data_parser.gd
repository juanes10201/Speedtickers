extends Node2D

@export var EditorPlace : Node2D

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

func GetSaveDataNodes(Nodes : Array) -> Array:
	print("Nodes: " + str(Nodes))
	var _result : Array = []
	for _node in Nodes:
		if(_node.has_meta(EditorPlace.NewNodeMetaNumber) && _node.has_meta(EditorPlace.NewNodeMetaSubNumber)):
			var _node_number = _node.get_meta(EditorPlace.NewNodeMetaNumber)
			var _node_subnumber = _node.get_meta(EditorPlace.NewNodeMetaSubNumber)
			print("node number: " + str(_node_number))
			print("node subnumber: " + str(_node_subnumber))
			
			var _original_packed_scene = EditorPlace.SelectableNodesLoaded[_node_number][_node_subnumber]
			var _original_scene_state = _original_packed_scene.get_state()
			
			var MainNodeId = 0
			for i in _original_scene_state.get_node_property_count(MainNodeId): #_original_scene_state.get_property_list():
				var _property_value = _original_scene_state.get_node_property_value(MainNodeId, i)
				var _property_name = _original_scene_state.get_node_property_name(MainNodeId, i)
				#if(property.name in _original_scene_state && _node.get(property.name) != _original_scene_state.get(property.name)):
				print("Property name: " + str(_property_name))
				print("Property value: " + str(_property_value))
			
			print("!!!!!: " + str(_original_scene_state))
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
	var Saved = GetSaveDataTiles(Tiles, Tilemap, SaveData)
	GetSaveDataNodes(Nodes)
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
