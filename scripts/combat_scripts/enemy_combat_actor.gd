extends CombatActor

class_name EnemyCombatActor

@export var numMovesPerRound : int

func _ready():
	
	CombatGlobal.enemyObjects.append(self)
	CombatGlobal.trackTimeline.tracks_placed.connect(place_ui)
	CombatGlobal.trackTimeline.tracks_placed.connect(populate_track)
	
	update_text()
	
func populate_track():
	
	print("Populating track")
	var frame_list = framesResources.get_resource_list()
	
	var rand_obj = RandomNumberGenerator.new()
	
	var origin_point := Vector2.ZERO
	
	for i in range(numMovesPerRound):
		
		var rand_index := rand_obj.randi_range(0, frame_list.size() - 1)
		
		var frame_instance = framesResources.get_resource(frame_list[rand_index])
		
		frame_instance = frame_instance.instantiate()
		
		frame_instance.set_mouse_areas(false)
		
		frame_instance.can_be_dragged_override = false
		
		frame_instance.combatActor = self
		
		print("Frame size of instance is " + str(frame_instance.frameSize))
		
		if(check_for_space(frame_instance.frameSize)):
			var tween = get_tree().create_tween()
			print("space found for spawned frames")
			add_child(frame_instance)
			frame_instance.global_position = origin_point
			tween.tween_property(frame_instance, "global_position", get_proper_position(listOfEmptyFrames), 0.5) 
			listOfSpawnedFrames.append(frame_instance)
			
		else:
			for j in frame_instance.tree_exiting.get_connections():
				frame_instance.tree_exiting.disconnect(j.callable)
			frame_instance.queue_free()
		
func check_for_space(frame_size : int):
	
	var empty_frame_counter : int
	
	var list_of_empty_frames := []
	
	for i in track.listOfFrames:
		
		if !i.occupied:
			
			empty_frame_counter += 1
			
			if(i not in list_of_empty_frames):
				
				list_of_empty_frames.append(i)
			
		else:
			
			list_of_empty_frames = []
			empty_frame_counter = 0
			
		if(empty_frame_counter == frame_size):
			
			listOfEmptyFrames = list_of_empty_frames
			
			for j in listOfEmptyFrames:
				
				j.set_occupied(true)
				
			print(track.get_occupied_frames())
			
			return true
			
	return false
	
func get_proper_position(list_of_empty_frames):
	
	var averaged_position : Vector2
	
	print("Placing frames")
	
	#print(listOfEmptyFrames)
	for i in list_of_empty_frames:
		
		print("Averaging position")
		
		averaged_position += i.global_position
		
	averaged_position = averaged_position / float(list_of_empty_frames.size())
	print(averaged_position)
	return averaged_position
	
func clear_track_frames():#Called in track_timeline
	
	for i in listOfSpawnedFrames:
		i.queue_free()
		
	listOfSpawnedFrames = []
	
	for i in track.listOfFrames:
		i.set_occupied(false)

func repopulate_track():
	populate_track()
