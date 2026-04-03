extends CharacterBody2D

enum Directions{
	Go = 1,
	Return = -1,
	none = 0
}
var Direction = Directions.Go
@export var SPEED = 50.0
const JUMP_VELOCITY = -400.0
@export var AccX : float = 30.0
@export var NeedToInteract : bool = true
@export var PauseGame : bool = false
@export var PointTo : Marker2D
@onready var InitialX : float = self.position.x
@onready var GoToX : float = PointTo.position.x if PointTo else 0.0
@onready var Sprite = $Sprite
var Move : bool = true
@export var Dialogue_Action : String = "npc_lobby1"
@export var OnlyOnce : bool = false
@export var RecordDialogueId : int = 0
@export var RecordOnlyOnce : bool = false
@onready var Player = SaveGame.get_player()
@export var HideAnim : bool = false
var Done : bool = false
var InDialogue : bool = false

func _ready() -> void:
	$DialogueTrigger.Action = Dialogue_Action
	$DialogueTrigger.NeedAction = NeedToInteract
	$DialogueTrigger.PauseGame = PauseGame
	$DialogueTrigger.OnlyOnce = OnlyOnce
	$DialogueTrigger.RecordDialogueId = RecordDialogueId
	$DialogueTrigger.RecordOnlyOnce = RecordOnlyOnce

func _physics_process(delta: float) -> void:
	if(Done || (!InDialogue && RecordOnlyOnce && SaveGame.GetDialogue(RecordDialogueId))):
		Done = true
		if(Sprite.animation != "hide"): Sprite.play("hide")
		return
	if(!Move && Player && self.global_position.distance_to(Player.global_position) > 250):
		Dialogic.end_timeline()
	if not is_on_floor():
		velocity += get_gravity() * delta
	if(PointTo && Move && !HideAnim):
		if(Sprite.animation != "hide"): Sprite.play("move")
		Sprite.speed_scale = velocity.x/SPEED
		$Sprite.scale.x = abs($Sprite.scale.x) if self.global_position.x-GoToX > 0 else abs($Sprite.scale.x)*-1
		if(Direction == Directions.Go): GoToX = PointTo.position.x
		elif(Direction == Directions.Return): GoToX = InitialX
		if(abs(GoToX - self.global_position.x) < 60):
			velocity.x = lerp(velocity.x, 0.0, 5*delta)
			if(abs(velocity.x) < 0.1): Direction *= -1
		elif(GoToX <= self.global_position.x):
			if(abs(velocity.x) < SPEED):
				velocity.x -= AccX*delta
		elif(GoToX >= self.global_position.x):
			if(abs(velocity.x) < SPEED):
				velocity.x += AccX*delta
	else:
		velocity.x = lerp(velocity.x, 0.0, 8*delta)
		if(Player): Sprite.scale.x = abs(Sprite.scale.x) if Player.global_position < Sprite.global_position else abs(Sprite.scale.x)*-1 
		if(Sprite.animation != "hide"): Sprite.play("interact")

	move_and_slide()

func _on_timeline_ended():
	if(OnlyOnce && HideAnim):
		Done = true
	Player._pause_game_no_menu(false)
	Move = true
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	InDialogue = false
