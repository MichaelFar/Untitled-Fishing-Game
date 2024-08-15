extends Node2D

@export var timeLineCursor : Area2D

@export var playerTrack : Node2D

@export var enemyTrack : Node2D

@export var activeFrameShapes : Array[CollisionShape2D]

func _ready():
	
	set_cursor_start(playerTrack.startPosition)
	
	place_cursor()
	
func _physics_process(delta):
	
	if(Input.is_action_just_released("cast")):
		
		tween_cursor_to_end()

func set_cursor_start(start_position : Vector2):

	timeLineCursor.global_position = start_position

func tween_cursor_to_end():
	
	
	if(timeLineCursor.global_position.x == playerTrack.startPosition.x 
	|| timeLineCursor.global_position.x == get_farthest_last_frame()):
		
		place_cursor()
		
		var tween = get_tree().create_tween()
		
		tween.tween_property(timeLineCursor, "global_position:x", get_farthest_last_frame(), 1.5)
		
		return tween

func _on_area_2d_body_entered(body):
	
	print("Body entered")
	
	if(body.is_in_group("draggable")):
		
		body.create_effect()
		
func place_cursor():
	
	activeFrameShapes[0].global_position.y = playerTrack.startPosition.y
	activeFrameShapes[1].global_position.y = enemyTrack.startPosition.y
	timeLineCursor.global_position.y = (playerTrack.startPosition.y + enemyTrack.startPosition.y) / 2.0
		
	timeLineCursor.global_position.x = playerTrack.startPosition.x

func get_farthest_last_frame():
	
	var a = playerTrack.endPosition.x
	var b = enemyTrack.endPosition.x
	
	return a if a > b else b
