extends Node2D

@export var timeLineCursor : Area2D

@export var cursorLine : Sprite2D

@export var activeFrameShapes : Array[CollisionShape2D]

@export var playerFramePool : Node2D#Used for positioning, for frame population see PlayerCombatActor

@export var playerCombatActor : CombatActor

@export var enemyCombatActor : CombatActor

@export var playerTrack : Node2D

@export var enemyTrack : Node2D

@export var playButton : TextureButton

@export var bubbleScene : PackedScene

var bubbleOdds := 2 #Represents the odds that a bubble will spawn, rolled against a d10

var hasSpawnedBubble = false

var longerTrackObject = null

signal cursor_reached_end

signal tracks_placed

func _init() -> void:
	
	CombatGlobal.trackTimeline = self
	
	bubbleOdds = PlayerStatGlobal.bubbleOdds
	
func _ready():
	
	get_farthest_last_frame()
	
	place_tracks()
	
	set_cursor_start(playerTrack.startPosition)
	
	place_cursor()
	
	enemyTrack.disable_children()

func _physics_process(delta: float) -> void:
	
	if(Input.is_action_just_released("Debug")):
		
		increase_track_size(playerTrack)
		

func increase_track_size(track_object):
	track_object.initialTrackFrames += 1
	place_cursor()
	

func set_cursor_start(start_position : Vector2):

	timeLineCursor.global_position = start_position

func tween_cursor_to_end():
	
	if(timeLineCursor.global_position.x == playerTrack.startPosition.x):
		
		for i in activeFrameShapes:
		
			i.disabled = false
		
		place_cursor()
		
		var tween = get_tree().create_tween()
		
		tween.tween_property(timeLineCursor, "global_position:x", get_farthest_last_frame(), 1.5)
		
		tween.finished.connect(emit_cursor_end)
		
		return tween 
		
	elif (timeLineCursor.global_position.x == get_farthest_last_frame()):
		
		for i in activeFrameShapes:
		
			i.disabled = true
			
		var tween = get_tree().create_tween()
		
		tween.tween_property(timeLineCursor, "global_position:x", playerTrack.startPosition.x, 0.2)
		
		tween.finished.connect(tween_cursor_to_end)
		

func emit_cursor_end():
	
	print("cursor reached end")
	playButton.disabled = false
	cursor_reached_end.emit()
	var rand_obj = RandomNumberGenerator.new()
	
	if(rand_obj.randi_range(0, 10) <= bubbleOdds):
		spawn_bubble()
	
	for i in activeFrameShapes:
		
		i.disabled = true
	
	enemyCombatActor.clear_track_frames()
	enemyCombatActor.repopulate_track()
	
	playerCombatActor.reset_armor()
	enemyCombatActor.reset_armor()
	
	for i in playerCombatActor.listOfSpawnedFrames:
		
		i.set_mouse_areas(true)

func spawn_bubble():
	
	#if(!hasSpawnedBubble):
	var bubble_instance = bubbleScene.instantiate()
	Globals.currentLevel.add_child(bubble_instance)
	bubble_instance.global_position = Vector2(0, -200)
	hasSpawnedBubble = true

func _on_area_2d_body_entered(body):
	
	print("Body entered")
	
	if(body.is_in_group("draggable")):
		print("Emitting triggered effect")
		body.triggered_effect.emit()
		
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
	
	playerFramePool.global_position = Vector2(start_position_x, player_start_position_y - playerFramePool.frameHeight)
	
	var enemy_start_position_y = (playerTrack.global_position.y) + playerTrack.frameHeight#player_start_position_y + (playerTrack.frameHeight * 1.5)
	
	enemyTrack.global_position = Vector2(start_position_x, enemy_start_position_y)
	
	playerTrack.set_start_and_end_positions()
	enemyTrack.set_start_and_end_positions()
	
	playButton.position.x = ((playerTrack.startPosition.x + get_farthest_last_frame()) / 2.0) - (playButton.texture_normal.get_width() / 2.0)
	playButton.position.y = playerTrack.frameHeight
	
	tracks_placed.emit()
	
func _on_pause_play_button_up() -> void:
	
	tween_cursor_to_end()
	
	for i in playerCombatActor.listOfSpawnedFrames:
		
		i.set_mouse_areas(false)
	
	playButton.disabled = true
