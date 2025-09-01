extends Node2D
@onready var StyleText = $StyleText
@onready var StyleBar = $StyleBar
@onready var StylePoints = $Points
@onready var StyleMoto = $Moto 
@onready var StyleSprite = $StyleSprite
@onready var Anim = $AnimationPlayer
@onready var MultText = $"Mult/MultText"
@onready var MultDiagonalBG = $"Mult/MultDiagonalBg"

var PlayedHideAnimation : bool = false

func _process(delta: float) -> void:
	#StyleText.text = " " + LevelManager.GetStyle()
	if(!Anim.is_playing() && !PlayedHideAnimation): Anim.play("Idle")
	
	MultText.text = str(LevelManager.ScoreMult)
	MultDiagonalBG.animation = str(LevelManager.ScoreMult)
	
	StyleSprite.animation = LevelManager.GetStyle()
	if(LevelManager.PreviousStyle != StyleSprite.animation):
		if(LevelManager.PreviousStyle == "D"):
			Anim.play("Show")
			LevelManager.StylePlayedHideAnimation = false
		elif(!Anim.is_playing()):
			Anim.play("ChangeRank")
		LevelManager.PreviousStyle = StyleSprite.animation
	if(LevelManager.PreviousScore != StylePoints.text && !PlayedHideAnimation && !Anim.is_playing()):
		LevelManager.PreviousScore = StylePoints.text
		Anim.play("ChangeScore")
	if(StyleSprite.animation == "D"):
		if(LevelManager && !LevelManager.StylePlayedHideAnimation):
			LevelManager.StylePlayedHideAnimation = true
			Anim.play("Hide")
		elif(Anim.current_animation != "Hide" || !Anim.is_playing()):
			Anim.play("Hiden")
	else:
		PlayedHideAnimation = false
	
	StyleBar.value = LevelManager.StyleTimer.time_left
	StylePoints.text = "X" + str(LevelManager.StyloMetter) + " Style"
	
	StyleMoto.text = str(LevelManager.ScoreMult) + "X " if LevelManager.ScoreMult > 1 else ""
	StyleMoto.text += LevelManager.StyleMoto
