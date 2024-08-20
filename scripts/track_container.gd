extends Node2D

@export var emptyFrameResources : ResourcePreloader

@export var initialTrackFrames : int

var listOfFrames : Array

var previousTrackFrame = null

var firstTrackFrame = null

var frame_count := 0

var startPosition : Vector2

var endPosition : Vector2

var frameHeight : float

func _ready():
	
	spawn_initial_track_frames()

func spawn_initial_track_frames():
	
	listOfFrames = []
	
	var frame_resource = emptyFrameResources.get_resource(emptyFrameResources.get_resource_list()[0])
	
	for i in range(initialTrackFrames):
		
		var frame_instance = frame_resource.instantiate()
		
		add_child(frame_instance)
		
		listOfFrames.append(frame_instance)
		
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
