extends Control
@export var User1 : RichTextLabel
@export var Place1 : RichTextLabel
@export var User2 : RichTextLabel
@export var Place2 : RichTextLabel
@export var User3 : RichTextLabel
@export var Place3 : RichTextLabel
@export var UserPlayer : RichTextLabel
@export var PlacePlayer : RichTextLabel

func _round_time_number(time : float) -> float:
	#La idea es redondear a un punto de decimal de minimo 3 unidades, si esta empatadado con otro incluir las decimales hasta que no este
	var q : int = 100
	return floor(time*q)/q

func _set_text_pos(Name : String, time : float) -> String:
	return str(Name)+": "+str(time)+" seg"

func _set_data(Level : int, IndexUser : int, TextUser : RichTextLabel):#, TextPlace : RichTextEffect):
	var UserDic : Dictionary = SaveGame.GetUserLevelDiccionary(Level, IndexUser)
	#Si no esta vacio
	if(!UserDic.is_empty()):
		TextUser.text = _set_text_pos(UserDic.name, UserDic.time)

func _update_best_scores(Level : int, World : int) -> void:
	var PlayerTime : float = _round_time_number(SaveGame.GetLevelTime(Level-1, World))
	if(UserPlayer): UserPlayer.text = _set_text_pos(SaveGame.GetPlayerUserName(), PlayerTime)
	_set_data(Level, 0, User1)
	_set_data(Level, 1, User2)
	_set_data(Level, 2, User3)
	
func _ready() -> void:
	_update_best_scores(0, 0)

func _process(delta: float) -> void:
	pass
