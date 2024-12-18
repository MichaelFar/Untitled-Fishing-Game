extends CombatActor

class_name PlayerCombatActor

@export var playerFramePool : Node2D

@export var originMarker : Marker2D

var listOfFrameResources := []

var listOfFrameIcons := []

func _ready() -> void:
	
	listOfFrameResources = framesResources.get_resource_list()
	
	CombatGlobal.playerObjects.append(self)
	CombatGlobal.trackTimeline.tracks_placed.connect(place_ui)
	CombatGlobal.trackTimeline.tracks_placed.connect(populate_track)
	PlayerStatGlobal.numPlayerFrames = framesResources.get_resource_list().size()
	update_text()
	
func get_proper_position(frame_instance, list_of_empty_frames, is_bubble_frame : bool = false):
	#For spawned draggable frames, this is where we must connect the signals and such
	var averaged_position : Vector2
	
	print("Placing frames")
	
	for i in list_of_empty_frames:
		print("Averaging position")
		
		averaged_position += i.global_position
		frame_instance.slotted_in_frame.connect(i.set_occupied)
		frame_instance.body_ref = i
		frame_instance.bodyRefArray.append(i)
		
	averaged_position = averaged_position / float(list_of_empty_frames.size())
	print(averaged_position)
	return averaged_position
	
func check_for_space(frame_size : int):
	
	var empty_frame_counter : int
	
	var list_of_empty_frames := []
	
	for i in playerFramePool.listOfFrames:
		
		if !i.occupied:
			
			empty_frame_counter += 1
			
			if(i not in list_of_empty_frames):
				
				list_of_empty_frames.append(i)
			
		else:
			
			list_of_empty_frames = []
			empty_frame_counter = 0
			
		if (empty_frame_counter == frame_size):
			
			listOfEmptyFrames = list_of_empty_frames
			
			for j in listOfEmptyFrames:
				
				j.set_occupied(true)
				
			print("Occupied frames: " + str(track.get_occupied_frames()))
			
			return true
			
	return false

func populate_track():
	
	print("Populating track")

	var rand_obj = RandomNumberGenerator.new()
	
	var origin_point := Vector2.ZERO
	
	for i in range(PlayerStatGlobal.numPlayerFrames):
		
		
		var index = clamp(i, 0, listOfFrameResources.size() - 1)
		
		add_new_frame_to_current_battle.bind(index, origin_point).call_deferred()
		

func add_new_frame_to_current_battle(index : int, origin_point : Vector2 = Vector2(0,0)):
	
	var frame_instance = framesResources.get_resource(listOfFrameResources[index])

	frame_instance = frame_instance.instantiate()
	
	print("Frame size of instance is " + str(frame_instance.frameSize))
	
	if(check_for_space(frame_instance.frameSize)):
		
		print("space found for spawned frames")
		add_child(frame_instance)
		
		frame_instance.global_position = origin_point
		
		var tween = get_tree().create_tween()
		tween.tween_property(frame_instance, "global_position", get_proper_position(frame_instance, listOfEmptyFrames), 0.5) 
		
		tween.finished.connect(frame_instance.set_mouse_areas.bind(true))
		
		listOfSpawnedFrames.append(frame_instance)
		frame_instance.combatActor = self
		frame_instance.dragging_frame.connect(set_other_pickable)
		frame_instance.set_mouse_areas(false)
		frame_instance.can_be_dragged_override = true
		listOfFrameIcons.append(frame_instance.texture.texture)
		
	else:
		
		for j in frame_instance.tree_exiting.get_connections():
			
			frame_instance.tree_exiting.disconnect(j.callable)
			
		frame_instance.queue_free()
		
	return frame_instance
	
func set_other_pickable(draggable_frame, new_value : bool):
	
	var exception_index = listOfSpawnedFrames.find(draggable_frame)
	
	for i in listOfSpawnedFrames:
		
		if(listOfSpawnedFrames[exception_index] != i):
			
			i.set_mouse_areas(new_value)

func set_frames_clickable(new_value : bool):
	
	for i in listOfSpawnedFrames:
		
			i.set_mouse_areas(new_value)
