extends LightOccluder2D

var viewPort : Viewport

func _ready():
	
	viewPort = get_viewport()
	
func _process(delta) -> void:
	
	global_position = viewPort.get_mouse_position()
