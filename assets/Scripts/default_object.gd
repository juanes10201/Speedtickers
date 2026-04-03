extends Node2D
class_name Editable

var Hovering : bool = false

var Dif : float = 10

func Editor_Hover_Check(x, y, MousePos : Vector2) -> bool:
	if(check_mouse_pos(x-Dif, y-Dif, x+Dif, y+Dif, MousePos)):
		return true
	else:
		print("NOT HOVERING")
		#print("X:" + str(x))
		#print("Y:" + str(y))
		#print("Mouse X: " + str(MousePos.x))
		#print("Mouse Y: " + str(MousePos.y))
	return false

func check_mouse_pos(x1 : float, y1 : float, x2 : float, y2 : float, MousePos : Vector2) -> bool:
	if(MousePos.x >= x1 && MousePos.y >= y1 && MousePos.x <= x2 && MousePos.y <= y2):
		return true
	return false
