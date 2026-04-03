extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveGame.loadgamedata()
	SongPlayer.MusicState = SongPlayer.MusicStates.menu

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
