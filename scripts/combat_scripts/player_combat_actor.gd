extends CombatActor

class_name PlayerCombatActor

@export var playerFramePool : Node2D

var listOfEmptyFrames := []

func _ready() -> void:
	
	CombatGlobal.playerObjects.append(self)
	CombatGlobal.trackTimeline.tracks_placed.connect(place_ui)
	CombatGlobal.trackTimeline.tracks_placed.connect(populate_track)
	update_text()
	
func get_proper_position(frame_instance, list_of_empty_frames):
	#For spawned draggable frames, this is where we must connect the signals and such
	var averaged_position : Vector2
	
	print("Placing frames")
	
	for i in list_of_empty_frames:
		
		print("Averaging position")
		
		averaged_position += i.global_position
		frame_instance.slotted_in_frame.connect(i.set_occupied)
		frame_instance.insideDropZone = true
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
				pass
				j.set_occupied(true)#When this line needs to be expanded because the corresponding frame becomes permanently unusable
				#If this line is disabled, the frames work, but the will all spawn overlapped
				
			print(track.get_occupied_frames())
			
			return true
			
	return false

func populate_track():
	
	print("Populating track")
	var frame_list = framesResources.get_resource_list()
	
	var rand_obj = RandomNumberGenerator.new()
	
	for i in range(PlayerStatGlobal.numPlayerFrames):
		
		var rand_index := rand_obj.randi_range(0, frame_list.size() - 1)
		
		var frame_instance = framesResources.get_resource(frame_list[rand_index])
		
		frame_instance = frame_instance.instantiate()
		
		frame_instance.disable_mouse_areas()
		print("Frame size of instance is " + str(frame_instance.frameSize))
		if(check_for_space(frame_instance.frameSize)):
			
			print("space found for spawned frames")
			add_child(frame_instance)
			frame_instance.global_position = get_proper_position(frame_instance, listOfEmptyFrames)
			#for j in listOfEmptyFrames:
				#if(j.global_position == frame_instance.global_position):
					#frame_instance.slotted_in_frame.connect(j.set_occupied)
				#j.slotted_in_frame.connect(j.set_occupied)#Refactor the signal to not be tied to the draggable_frame script
		else:
			
			frame_instance.queue_free()
		
