extends Node2D
@export var Var : String = "Shake"
@export var ShowOnCondition : bool = false
@export var ConditionVar : String = "Cheats"
@onready var Status : bool = true
@export var Enabled : bool = true

func _process(delta: float) -> void:
	var _s = SaveGame.get_config_value(Var)
	if(_s != null): Status = _s
	$EnabledState.animation = str(Status)
	if(ShowOnCondition):
		if(SaveGame.get_config_value(ConditionVar) == 1):
			Enabled = true
			$EnabledState.animation = str(Status)
			modulate.a = 1
		else:
			Enabled = false
			$EnabledState.animation = "false"
			modulate.a = 0.3

func _ready() -> void:
	var _s = SaveGame.get_config_value(Var)
	print("Condition " + Var + " is " + str(_s))
	if(_s != null): Status = _s
	$EnabledState.animation = str(Status)

func _on_button_pressed() -> void:
	if(!Enabled): return
	print("Config " + Var + " set to " + str(!Status))
	SaveGame.set_config_value(Var, int(!Status))
	Status = !Status
	$EnabledState.animation = str(Status)
