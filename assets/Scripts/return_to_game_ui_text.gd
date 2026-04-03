extends RichTextLabel

@onready var Player = $"../../Player"
@onready var Time_Left = null if !Player else Player.ReturnToGameTime

@onready var original_size = get_theme_font_size("normal_font_size")
@onready var Font_Size = get_theme_font_size("normal_font_size")

@export var change_size_multiplier : float = 1.2
@onready var previous_time = Time_Left

@onready var number = null
var current_text = "" 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(Time_Left): number = get_node( "counter" + str(Time_Left.wait_time))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Time_Left):
		current_text = str(int(floor(Time_Left.time_left*2)))
		if(current_text != "0"): self.text = "[center]" + current_text + "[center]"
		else: self.text = "[center]!!!![center]"
		#Trigger death when timer runs out
		if(Time_Left.time_left <= 0): hide()
		else: show()
		
		if(str(self.text) != str(previous_time)):
			previous_time = current_text
			add_theme_font_size_override("normal_font_size", 10)
			Font_Size = original_size * change_size_multiplier
			
			if(number): number.stop()
			var number = get_node_or_null( "counter" + str(current_text) )
			if(number): number.play()
	Font_Size = lerpf(Font_Size, original_size, 5  * delta)
	
	#Apply font change
	if(get_theme_font_size("normal_font_size") != Font_Size): add_theme_font_size_override("normal_font_size", Font_Size)
	
