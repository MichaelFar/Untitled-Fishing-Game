extends Area2D

@export var subviewPort : SubViewport

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	subviewPort.handle_input_locally = true
	
	subviewPort.push_input(event)

	# This line is a hack, that needs to be removed after https://github.com/godotengine/godot/pull/77926 gets merged
	subviewPort.handle_input_locally = false
