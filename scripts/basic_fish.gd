extends CharacterBody3D

@export var animationPlayer : AnimationPlayer

@export var navAgent : NavigationAgent3D

@export var idleTimer : Timer

@export var fishSpeed := 0.5

@export var angularAcceleration := 2.0 #Turns out 3d rotation is extra like that

@export var debugSphere := MeshInstance3D

var waterMeshOrigin = Vector2.ZERO

var chosenPosition := Vector3.ZERO

var currentState = FISHSTATE.MOVE

var isInterested := false

var bitingHook := false

var bobberGlobalPosition = Vector3.ZERO

var globalDelta := 0.0

enum FISHSTATE {
	MOVE,#Move to chosen point
	IDLE,#Idle at chosen point
	INTEREST,#Bait has gained interest in fish
	NIBBLE
}

var BAIT_INTEREST_DICT = {Globals.BAITS.LEECHES: 15, 
Globals.BAITS.GRUBS : 20, 
Globals.BAITS.WORMS : 100}

func _ready():
	
	call_deferred("actor_setup")
	scale = resize()

func _physics_process(delta):
	globalDelta = delta
	var current_agent_position: Vector3
	var next_path_position: Vector3
	
	match currentState:
		
		FISHSTATE.MOVE:
			
			current_agent_position = global_position
			next_path_position = navAgent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * fishSpeed
			#print("Moving...")
			if(!animationPlayer.is_playing()):
				
				animationPlayer.play("looping_swim")
				
			if(next_path_position != global_position):
				
				rotate_towards_velocity(delta)
				
		FISHSTATE.IDLE:
			
			if(idleTimer.is_stopped()):
				
				idleTimer.start()
				
		FISHSTATE.INTEREST:
			
			current_agent_position = global_position
			next_path_position = navAgent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * fishSpeed
			print("Fish destination is " + str(next_path_position) + " and bobber is located at " + str(bobberGlobalPosition))
			if(next_path_position != global_position):	
				rotate_towards_velocity(delta)
			if(bitingHook):
				rotation.x = lerp_angle(rotation.x, atan2(-Vector3.UP.x, -Vector3.UP.z), delta)
	debugSphere.global_position = next_path_position
	move_and_slide()

func set_water_mesh_origin(water_mesh_origin):
	
	waterMeshOrigin = water_mesh_origin
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(get_random_position())
	
func get_random_position() -> Vector3:
	
	var randnum = RandomNumberGenerator.new()
	var chosen_position := Vector3.ZERO
	#Remember, x and z are the "2d" coordinates not x and y. Y is always up
	chosen_position.x = randnum.randf_range(waterMeshOrigin.x, Globals.currentWaterDimension.x)
	chosen_position.z = randnum.randf_range(waterMeshOrigin.y, Globals.currentWaterDimension.y)
	chosen_position.y = global_position.y
	return chosen_position
	
func set_movement_target(movement_target: Vector3):
	navAgent.set_target_position(movement_target)

func _on_idle_timer_timeout():
	
	set_movement_target(get_random_position())
	currentState = FISHSTATE.MOVE

func _on_navigation_agent_3d_target_reached():
	
	velocity = Vector3.ZERO
	print("Reached destination")
	if(!isInterested):
		
		currentState = FISHSTATE.IDLE
	else:
		print("Fish bit lure")
		bitingHook = true
		

func poll_interest(bait_key):
	
	var randnum = RandomNumberGenerator.new()
	
	var poll_result = randnum.randi_range(1, 100)
	
	print("Interest result is " + str(poll_result))
	var target = BAIT_INTEREST_DICT[bait_key]
	
	if(poll_result <= target && isInterested == false):
		print("Fish is interested")
		currentState = FISHSTATE.INTEREST
		isInterested = true
		set_movement_target(bobberGlobalPosition)
		idleTimer.stop()

func _on_detection_box_area_entered(area):
	
	area.get_parent().polling_interest.connect(poll_interest)
	bobberGlobalPosition = area.get_parent().global_position
	print("Fish entered")

func _on_detection_box_area_exited(area):
	
	print("Disconnecting signal")
	area.get_parent().disconnect("polling_interest", poll_interest)
	if(isInterested):
		set_movement_target(get_random_position())
		currentState = FISHSTATE.MOVE
		isInterested = false
	if(bitingHook):
		queue_free()
		get_parent().currentFishNum -= 1
		
func resize():
	
	var randnum = RandomNumberGenerator.new()
	
	var scale_max = scale / 2.0
	
	var new_scale = randnum.randf_range(-scale_max.x, scale_max.x)
	
	return scale + Vector3(new_scale,new_scale,new_scale)
	
func rotate_towards_velocity(delta):
	
	rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * angularAcceleration)# Thank you youtube guy holy goddamn
	
