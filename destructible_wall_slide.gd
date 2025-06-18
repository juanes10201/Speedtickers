extends StaticBody2D

# Custom variable to check if the wall is sliding
var Sliding: bool = false

func destroy():
	queue_free()  # Remove the wall from the scene
