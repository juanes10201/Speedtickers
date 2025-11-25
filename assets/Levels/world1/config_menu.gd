extends CanvasLayer

var Selected_Category : Global.ConfigCategories = Global.ConfigCategories.audio

func _init() -> void:
	SaveGame.loadgamedata()
