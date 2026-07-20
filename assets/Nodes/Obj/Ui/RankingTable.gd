extends Sprite2D

@export var TextTime : RichTextLabel
@export var TextTimeMult : RichTextLabel
@export var TextAvgStyle : RichTextLabel

@onready var OriginalTextTime = TextTime.text if TextTime else ""
@onready var OriginalTextTimeMult = TextTimeMult.text if TextTimeMult else ""
@onready var OriginalTextAvgStyle = TextAvgStyle.text if TextAvgStyle else ""

@export var StyleSprite : AnimatedSprite2D

func _ready() -> void:
	pass # Replace with function body.


func format(time : Vector2) -> String:
	return str(int(time.x))+":"+str(int(round(time.y)))

func _process(delta: float) -> void:
	if(TextTime && TextTimeMult && TextAvgStyle && StyleSprite): 
		var LetterStyle : String = LevelManager.GetStyle(Global.TextAvgStyle)
		TextAvgStyle.text = OriginalTextAvgStyle + str(Global.TextAvgStyle)
		StyleSprite.animation = LetterStyle
		
		TextTime.text = OriginalTextTime + str(format(Global.WorldTimeMin))
		TextTimeMult.text = OriginalTextTimeMult + str(Global.WorldTimeMult)
