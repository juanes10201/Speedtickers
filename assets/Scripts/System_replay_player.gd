extends Node2D

@export var State = Global.ReplayStates.STOPPED

var CurrentTime : float = 0
var ReplayCurrentAction : int = 0

@onready var Player = get_parent()


var Actions : Array[String] = ["player_jump", "player_slide", "player_dash", "ui_left", "ui_right", "reset"]

var ReplayActions = {
	"player_jump": false,
	"player_slide": false,
	"player_dash": false,
	"ui_left": false,
	"ui_right": false,
	"reset": false
	}

func _ready() -> void:
	State = Player.ReplayAction
	ReplayCurrentAction = 0
	CurrentTime = 0

func Reset() -> void:
	Player.position = Player.OriginalPos
	ReplayCurrentAction = -1
	CurrentTime = -0.5
	for i in ReplayActions:
		ReplayActions[i] = false

func Play_action(A : String, Press : int):
	print("Simulating Press of Action of type: " + str(A) + ", Condition: " + str(Press))
	if(A == "reset"):
		Reset()
		return
	if(Press == 1):
		ReplayActions[A] = true
	else:
		ReplayActions[A] = false

func Record_Actions() -> void:
	for i in range(Actions.size()):
		if(Input.is_action_just_pressed(Actions[i])):
			var RecordedAction : Vector3 = Vector3(CurrentTime, i, 1)
			Player.RecordedActions.append(RecordedAction)
			#print("Vector3" +str(RecordedAction) + ",")
		elif(Input.is_action_just_released(Actions[i])):
			var RecordedAction : Vector3 = Vector3(CurrentTime, i, 0)
			Player.RecordedActions.append(RecordedAction)
			#print("Vector3" +str(RecordedAction) + ",")

func Replay_Actions() -> void:
	#Check if the action time is the same(Or less) as the current
	if(ReplayCurrentAction < Player.RecordedActions.size() && CurrentTime >= Player.RecordedActions[ReplayCurrentAction].x):
		Play_action(Actions[Player.RecordedActions[ReplayCurrentAction].y], Player.RecordedActions[ReplayCurrentAction].z)
		ReplayCurrentAction += 1

#the idea is to check every frame is the player action is pressed, then record
func _process(delta: float) -> void:
	#print(Input.is_action_pressed("replay_player_jump"))
	CurrentTime += 1 * delta
	if(State == Global.ReplayStates.RECORD): Record_Actions()
	elif(State == Global.ReplayStates.REPLAY): Replay_Actions()
