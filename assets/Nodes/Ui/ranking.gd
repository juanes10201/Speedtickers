extends Control
@export var User1 : RichTextLabel
@export var Place1 : RichTextLabel
@export var User2 : RichTextLabel
@export var Place2 : RichTextLabel
@export var User3 : RichTextLabel
@export var Place3 : RichTextLabel
@export var UserPlayer : RichTextLabel
@export var PlacePlayer : RichTextLabel

func _set_text_pos(Name : String, time : float) -> String:
	return str(Name)+": "+str(time)

func _update_best_scores(Level : int) -> void:
	var PlayerTime : int = SaveGame.GetLevelTime(Level)
	if(UserPlayer): UserPlayer.text = _set_text_pos(SaveGame.GetPlayerUserName(), PlayerTime)

func _ready() -> void:
	_update_best_scores(0)

func _process(delta: float) -> void:
	pass
