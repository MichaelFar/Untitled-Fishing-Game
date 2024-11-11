extends Node2D

@export var emptyFrameResources : ResourcePreloader

@export var PatchRect : NinePatchRect

@export var initialTrackFrames : int :
	
	set(value):

		if(initialTrackFrames == 0):
			
			await ready
			initialTrackFrames = value
			spawn_track_frames()
			set_nine_patch_size(initialTrackFrames)
			
		else:
			initialTrackFrames = value
			spawn_track_frames()
			set_nine_patch_size(initialTrackFrames)

var listOfFrames : Array

var previousTrackFrame = null

var firstTrackFrame = null

var frame_count := 0

var frame_resource = null#emptyFrameResources.get_resource(emptyFrameResources.get_resource_list()[0])

var startPosition : Vector2

var endPosition : Vector2

var frameHeight : float

func _ready():
	pass
	#spawn_track_frames()


func spawn_track_frames():
	
	for i in range(initialTrackFrames - listOfFrames.size()):
		
		listOfFrames.append(spawn_frame())
	
func set_nine_patch_size(new_size : int):
	
	var tween = get_tree().create_tween()
	tween.tween_property(PatchRect, "size:x", frameHeight * new_size, 0.2)
	
func spawn_frame():
	
	frame_resource = emptyFrameResources.get_resource(emptyFrameResources.get_resource_list()[0])
	
	var frame_instance = frame_resource.instantiate()
	
	add_child(frame_instance)
	print("Spawning frame")
	if(previousTrackFrame == null):
		
		previousTrackFrame = frame_instance
		firstTrackFrame = frame_instance
		startPosition = previousTrackFrame.frameStart.global_position
		
		print("Start position is " + str(startPosition))
		
	else:
		
		frame_instance.global_position = previousTrackFrame.nextFrameLocation.global_position
		
		previousTrackFrame = frame_instance
	
	endPosition = previousTrackFrame.frameEnd.global_position
	frameHeight = previousTrackFrame.frameHeight
	
	return frame_instance

func get_occupied_frames():
	
	var occupied_array : Array
	
	for i in listOfFrames:
		
		occupied_array.append(i.occupied)
		
	return occupied_array

func _on_timer_timeout():
	
	print(get_occupied_frames())

func set_start_and_end_positions():
	
	startPosition = firstTrackFrame.frameStart.global_position
	endPosition = previousTrackFrame.frameEnd.global_position

func disable_children():
	
	for i in get_children():
		
		if i.is_in_group("droppable"):
			
			i.toggle_collision_bodies()
