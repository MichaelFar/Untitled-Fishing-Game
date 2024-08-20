extends Node2D

@export var timeLineCursor : Area2D

@export var activeFrameShapes : Array[CollisionShape2D]

@export var playerTrack : Node2D

@export var enemyTrack : Node2D

signal cursor_reached_end

func _ready():
	
	place_tracks()
	
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
		
		tween.finished.connect(emit_cursor_end)
		
		return tween

func emit_cursor_end():
	
	print("cursor reached end")
	cursor_reached_end.emit()

func _on_area_2d_body_entered(body):
	
	print("Body entered")
	
	if(body.is_in_group("draggable")):
		
		body.create_effect()
		
func place_cursor():
	
	
	timeLineCursor.global_position.y = (playerTrack.startPosition.y + enemyTrack.startPosition.y) / 2.0
		
	timeLineCursor.global_position.x = playerTrack.startPosition.x
	activeFrameShapes[0].global_position.y = playerTrack.global_position.y
	activeFrameShapes[1].global_position.y = enemyTrack.global_position.y
func get_farthest_last_frame():
	
	var a = playerTrack.endPosition.x
	var b = enemyTrack.endPosition.x
	
	return a if a > b else b

func place_tracks():
	
	var viewport_rect = get_viewport_rect()
	
	var start_position_x = viewport_rect.end.x / 4.0
	
	var player_start_position_y = viewport_rect.size.y / 3.0
	
	var enemy_start_position_y = player_start_position_y + (playerTrack.frameHeight * 1.5)
	
	playerTrack.global_position = Vector2(start_position_x, player_start_position_y)
	
	enemyTrack.global_position = Vector2(start_position_x, enemy_start_position_y)
	
	playerTrack.set_end_position()
	
	enemyTrack.set_end_position()
	
