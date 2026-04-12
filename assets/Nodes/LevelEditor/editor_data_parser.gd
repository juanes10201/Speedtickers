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

func SaveDataTiles(Tiles : Array, Tilemap : TileMapLayer, SaveData : Dictionary) -> void:
	var Current : int = 0
	var Saved : Dictionary[Vector2i, String] = { }
	#print(floor(-0.25))
	for Tile in Tiles:
		var Chunk : Vector2i = Vector2i(floor(float(Tile.x)/float(ChunkSize)), floor(float(Tile.y)/float(ChunkSize)) )
		var ChunkPos : Vector2i = Vector2i(abs(Tile.x % ChunkSize), -1*abs(abs(Tile.y % ChunkSize)-ChunkSize))
		if(Tile.x < 0): ChunkPos.x = ChunkSize - abs(ChunkPos.x)
		if(Tile.y > 0): ChunkPos.y = abs(ChunkPos.y)
		ChunkPos = Vector2(clamp(ChunkPos.x, -ChunkSize, ChunkSize), clamp(ChunkPos.y, -ChunkSize, ChunkSize))
		var ChunkIndex : int = clamp(ChunkPos.x - (ChunkPos.y * ChunkSize), -(ChunkSize*ChunkSize)-1, (ChunkSize*ChunkSize)-1)
		print(ChunkPos)
		Current += 1
		if(!Chunk in Saved): Saved[Chunk] = ChunkDefaultValue
		var tiledata : TileData = Tilemap.get_cell_tile_data(Tile)
		##El valor del autotile se guarda en hexabinario porque why not
		Saved[Chunk][ChunkIndex] = char(65+abs(tiledata.terrain))
	print(Saved)
	Clipboard = Saved

func LoadDataTiles(Tilemap : TileMapLayer, SaveData : Dictionary) -> void:
	for Chunk in SaveData:
		for Index in range(0, SaveData[Chunk].length()):
			var Pos : Vector2i = Vector2i(Chunk.x*ChunkSize+ Index%ChunkSize, Chunk.y*ChunkSize+ Index/ChunkSize)
			print(Pos)
			if(SaveData[Chunk][Index] == 'Z'):
				EditorPlace._erase_tile_terrain_local_pos(Pos)
			else:
				var SubTile : int = SaveData[Chunk][Index].unicode_at(0) - 65
				print(SubTile)
				EditorPlace._place_tile_terrain_local_pos(Pos, EditorPlace.SelectedTilemap, SubTile)
