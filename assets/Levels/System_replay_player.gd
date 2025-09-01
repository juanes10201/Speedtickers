extends Node2D

enum States{
	REPLAY,
	RECORD,
	STOPPED
}
@export var State = States.REPLAY

var Actions : Array[String] = ["player_jump", "player_slide", "player_dash", "ui_left", "ui_right"]

var RecordedActions : Array[Vector3] = [
	Vector3(2, 4.0, 1.0),
	Vector3(2, 4.0, 1.0)
]

var CurrentTime : float = 0
var ReplayCurrentAction : int = 0

func Play_action(A : int, Press : int):
	var event = InputEventAction.new()
	event.action = Actions[A]
	event.pressed = true if Press == 0 else false
	Input.parse_input_event(event)

func Record_Actions() -> void:
	for i in range(Actions.size()):
		if(Input.is_action_just_pressed(Actions[i])):
			var RecordedAction : Vector3 = Vector3(CurrentTime, i, 1)
			RecordedActions.append(RecordedAction)
			print("Vector3" +str(RecordedAction) + ",")
		elif(Input.is_action_just_released(Actions[i])):
			var RecordedAction : Vector3 = Vector3(CurrentTime, i, 0)
			RecordedActions.append(RecordedAction)
			print("Vector3" +str(RecordedAction) + ",")

func Replay_Actions() -> void:
	#Check if the action time is the same(Or less) as the current
	if(RecordedActions.size() > ReplayCurrentAction+1 && CurrentTime >= RecordedActions[ReplayCurrentAction][0]):
		ReplayCurrentAction += 1
		Play_action(RecordedActions[ReplayCurrentAction][1], RecordedActions[ReplayCurrentAction][2])

#the idea is to check every frame is the player action is pressed, then record
func _process(delta: float) -> void:
	CurrentTime += 1 * delta
	if(State == States.RECORD): Record_Actions()
	elif(State == States.REPLAY): Replay_Actions()
