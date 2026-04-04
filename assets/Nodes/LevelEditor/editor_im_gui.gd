extends Node2D

@export var EditorPlace : Node2D
var AnalizedBody : Node2D = null
@export var Editor : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func AnalizeBody(Body : Node2D) -> void:
	AnalizedBody = Body

func AnalizeAdvancedBodyTick() -> void:
	if(AnalizedBody):
		ImGui.Text("All variables in " + str(AnalizedBody.name))
		for property in AnalizedBody.get_property_list() :
			if(property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
				ImGui.Text(property.name + ": " + str(AnalizedBody.get(property.name)))

func ImGuiShowProperty(property):
	#Enum
	if property.type == TYPE_INT && property.hint == PROPERTY_HINT_ENUM:
		var options : PackedStringArray = property.hint_string.split(",")
		var arr := [AnalizedBody.get(property.name) as int]
		if ImGui.Combo(property.name, arr, options):
			AnalizedBody.set(property.name, arr[0])
		#all other data types
	else:
		match property.type:
			TYPE_BOOL:
				var arr := [AnalizedBody.get(property.name)]
				if(ImGui.Checkbox(property.name, arr )):
					AnalizedBody.set(property.name, arr[0])
			TYPE_INT:
				var arr := [AnalizedBody.get(property.name)]
				if(ImGui.InputInt(property.name, arr )):
					AnalizedBody.set(property.name, arr[0])
			TYPE_FLOAT:
				var arr := [AnalizedBody.get(property.name)]
				if(ImGui.InputFloat(property.name, arr )):
					AnalizedBody.set(property.name, arr[0])

func AnalizeBodyTick() -> void:
	if(AnalizedBody):
		ImGui.Text("Inspecting " + str(AnalizedBody.name))
		for property in AnalizedBody.get_property_list() :
			if(property.usage & PROPERTY_USAGE_EDITOR && property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
				######Esto cambia dependiendo del tipo d variable######
				ImGuiShowProperty(property)
						#_:
						#	ImGui.Text(property.name + ": " + str(AnalizedBody.get(property.name)))

#func AddPropertyUi(Property) -> void:
#	

func _process(delta):
	ImGui.Begin("Node Parameters")
	AnalizeBodyTick()
	ImGui.End()
	if(Editor.AdvancedMode):
		AnalizeAdvancedBodyTick()
	if(EditorPlace.LastCollidedBody != AnalizedBody):
		AnalizeBody(EditorPlace.LastCollidedBody)
