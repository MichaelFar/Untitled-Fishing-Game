extends Node2D

@export var timeLineCursor : Line2D

@export var playerTrack : Node2D


func _ready():
	
	set_cursor_start(playerTrack.startPosition)
	
func _physics_process(delta):
	
	if(Input.is_action_just_released("cast")):
		
		tween_cursor_to_end()

func set_cursor_start(start_position : Vector2):

	timeLineCursor.global_position = start_position

func tween_cursor_to_end():
	
	
	if(timeLineCursor.global_position == playerTrack.startPosition 
	|| timeLineCursor.global_position == playerTrack.endPosition):
		
		var tween = get_tree().create_tween()
		
		timeLineCursor.global_position = playerTrack.startPosition
		
		tween.tween_property(timeLineCursor, "global_position", playerTrack.endPosition, 1.5)
		
		return tween





func _on_area_2d_area_entered(area):
	print("Body entered")
	if(area.owner.is_in_group("draggable")):
		area.owner.create_effect()
