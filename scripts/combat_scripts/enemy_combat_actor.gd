extends CombatActor

class_name EnemyCombatActor

var listOfEmptyFrames = []

@export var numMovesPerRound : int

func _ready():
	
	track.get_parent().tracks_placed.connect(populate_track)#Dont use get_parent
	
func populate_track():
	print("Populating track")
	var frame_list = framesResources.get_resource_list()
	
	var rand_obj = RandomNumberGenerator.new()
	
	for i in range(numMovesPerRound):
		
		var rand_index := rand_obj.randi_range(0, frame_list.size() - 1)
		
		var frame_instance = framesResources.get_resource(frame_list[rand_index])
		
		frame_instance = frame_instance.instantiate()
		
		if(check_for_space(frame_instance.frameSize)):
			print("space found for spawned frames")
			add_child(frame_instance)
			frame_instance.global_position = get_proper_position(listOfEmptyFrames)
		else:
			frame_instance.queue_free()
		
func check_for_space(frame_size : int):
	
	var empty_frame_counter : int
	
	var list_of_empty_frames := []
	
	var occupied_list = track.get_occupied_frames()
	
	for i in track.listOfFrames:
		print("Looking at occupied list")
		if !i.occupied:
			
			empty_frame_counter += 1
			print("Appended frame is " + str(i))
			if(i not in list_of_empty_frames):
				list_of_empty_frames.append(i)
			
		else:
			
			list_of_empty_frames = []
			empty_frame_counter = 0
			
		if (empty_frame_counter == frame_size):
			listOfEmptyFrames = list_of_empty_frames
			for j in listOfEmptyFrames:
				j.set_occupied(true)
			print(track.get_occupied_frames())
			print("List of empty frames is " + str(listOfEmptyFrames))
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
