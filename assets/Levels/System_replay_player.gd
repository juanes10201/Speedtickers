extends Node2D

@export var State = Global.ReplayStates.STOPPED

var Actions : Array[String] = ["player_jump", "player_slide", "player_dash", "ui_left", "ui_right", "reset"]

var CurrentTime : float = 0
var ReplayCurrentAction : int = 0

@onready var Player = get_parent()

func _ready() -> void:
	State = Player.ReplayAction
	ReplayCurrentAction = 0
	CurrentTime = 0
	for i in range(Actions.size()):
		Play_action(i, 0)

func Play_action(A : int, Press : int):
	print("Simulating Press of Action of type: " + str(A) + ", Condition: " + str(Press))
	var event = InputEventAction.new()
	event.action = "replay_" + Actions[A]
	event.pressed = true if Press == 1.0 else false
	Input.parse_input_event(event)

func Record_Actions() -> void:
	for i in range(Actions.size()):
		if(Input.is_action_just_pressed(Actions[i])):
			var RecordedAction : Vector3 = Vector3(CurrentTime, i, 1)
			Player.RecordedActions.append(RecordedAction)
			print("Vector3" +str(RecordedAction) + ",")
		elif(Input.is_action_just_released(Actions[i])):
			var RecordedAction : Vector3 = Vector3(CurrentTime, i, 0)
			Player.RecordedActions.append(RecordedAction)
			print("Vector3" +str(RecordedAction) + ",")

func Replay_Actions() -> void:
	#Check if the action time is the same(Or less) as the current
	if(ReplayCurrentAction < Player.RecordedActions.size() && CurrentTime >= Player.RecordedActions[ReplayCurrentAction].x):
		Play_action(Player.RecordedActions[ReplayCurrentAction].y, Player.RecordedActions[ReplayCurrentAction].z)
		ReplayCurrentAction += 1

#the idea is to check every frame is the player action is pressed, then record
func _process(delta: float) -> void:
	print(Input.is_action_pressed("replay_player_jump"))
	CurrentTime += 1 * delta
	if(State == Global.ReplayStates.RECORD): Record_Actions()
	elif(State == Global.ReplayStates.REPLAY): Replay_Actions()
