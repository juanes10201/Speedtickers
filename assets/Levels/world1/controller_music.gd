extends HSlider

@export var Audio_Bus_Name : String

var Audio_Bus_Id : int

func _ready():
	Audio_Bus_Id = AudioServer.get_bus_index(Audio_Bus_Name)

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(Audio_Bus_Id, value)
