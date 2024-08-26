extends Node2D

@export var timeLineCursor : Area2D

@export var activeFrameShapes : Array[CollisionShape2D]

@export var playerTrack : Node2D

@export var enemyTrack : Node2D

@export var playButton : TextureButton

var longerTrackObject = null

signal cursor_reached_end

signal tracks_placed

func _ready():
	
	get_farthest_last_frame()
	
	place_tracks()
	
	set_cursor_start(playerTrack.startPosition)
	
	place_cursor()
	
	enemyTrack.disable_children()
	
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
	playButton.disabled = false
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
	
	var player_end_pos = playerTrack.endPosition.x
	var enemy_end_pos = enemyTrack.endPosition.x
	
	longerTrackObject = playerTrack if player_end_pos > enemy_end_pos else enemyTrack
	
	return player_end_pos if player_end_pos > enemy_end_pos else enemy_end_pos

func place_tracks():
	
	var viewport_rect = get_viewport_rect()
	
	var start_position_x = (viewport_rect.end.x / 2.0) - ((longerTrackObject.initialTrackFrames * longerTrackObject.frameHeight) / 3.0)
	
	var player_start_position_y = viewport_rect.size.y / 1.5
	
	playerTrack.global_position = Vector2(start_position_x, player_start_position_y)
	
	var enemy_start_position_y = (playerTrack.global_position.y) + playerTrack.frameHeight#player_start_position_y + (playerTrack.frameHeight * 1.5)
	
	enemyTrack.global_position = Vector2(start_position_x, enemy_start_position_y)
	
	playerTrack.set_start_and_end_positions()
	enemyTrack.set_start_and_end_positions()
	
	playButton.position.x = ((playerTrack.startPosition.x + get_farthest_last_frame()) / 2.0) - (playButton.texture_normal.get_width() / 2.0)
	playButton.position.y = playerTrack.frameHeight
	
	tracks_placed.emit()
	
func _on_pause_play_button_up() -> void:
	
	tween_cursor_to_end()
	playButton.disabled = true
