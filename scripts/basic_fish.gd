class_name BasicFish

extends CharacterBody3D

@export var animationPlayer : AnimationPlayer

@export var navAgent : NavigationAgent3D

@export var idleTimer : Timer

@export var debugSphere := MeshInstance3D

@export var detectionBox : Area3D

@export var navDetectionBox : Area3D

@export var minigamePreloader : ResourcePreloader

@export var FiniteStateMachine : FiniteStateMachine

@export var fishSpeed := 0.5

@export var angularAcceleration := 2.0 #Turns out 3d rotation is extra like that

var fishResource : Resource #Set in spawner as the PackedScene of this fish

var waterMeshOrigin = Vector2.ZERO

var chosenPosition := Vector3.ZERO

var currentState = FISHSTATE.SPAWNMOVE

var isInterested := false

var bitingHook := false

var bobberGlobalPosition = Vector3.ZERO

var spawnDestination = Vector3.ZERO #When fish spawn, they swim up to this 

var globalDelta := 0.0

var couldBeBiting := false

var biteZoneID = null

var wasRespawned := false

var minigame = null

var currentDifficulty := LevelTransition.DIFFICULTY.EASY

signal biting #Emits when fish bites the bobber, signal is connected to a bobber object function

enum FISHSTATE {
	SPAWNMOVE,#When spawned swim up
	MOVE,     #Move to chosen point
	IDLE,     #Idle at chosen point
	INTEREST, #Fish has gained interest in bait
	NIBBLE
}

var BAIT_INTEREST_DICT = {
	
	Globals.BAITS.LEECHES : 15, 
	
	Globals.BAITS.GRUBS   : 5, 
	
	Globals.BAITS.WORMS   : 100
	
	}
func _ready():
	
	call_deferred("actor_setup")
	
	scale = resize()
	
	animationPlayer.play("looping_swim")
	
	if(PlayerStatGlobal.fishCurrentlyBiting.size() != 0):#If the fish spawns in and there is already a fish on the hook
		
		detectionBox.monitoring = false
		
	Globals.connectBitingSignal()
	
	minigame = choose_minigame()
	
	print("Stored minigame is " + str(minigame))
	
func _physics_process(delta):
	
	globalDelta = delta
	
	var current_agent_position: Vector3
	
	var next_path_position: Vector3
	
	match currentState:
		
		FISHSTATE.SPAWNMOVE:
			pass
			#rotation.x = lerp_angle(rotation.x, atan2(-Vector3.UP.x, -Vector3.UP.z), delta)
			#
			#var modified_spawn_destination = Vector3(global_position.x, spawnDestination.y, global_position.z)
			#
			#velocity = global_position.direction_to(modified_spawn_destination) * fishSpeed
		
		FISHSTATE.MOVE:
			
			current_agent_position = global_position
			
			next_path_position = navAgent.get_next_path_position()
			
			velocity = current_agent_position.direction_to(next_path_position) * fishSpeed
			
			if(next_path_position != global_position):
				
				rotation.x = lerp_angle(rotation.x,atan2(-Vector3.FORWARD.x, -Vector3.FORWARD.z), delta * angularAcceleration)
				
				rotate_towards_velocity(delta)
				
		FISHSTATE.IDLE:
			
			if(idleTimer.is_stopped()):
				
				idleTimer.start()
				
		FISHSTATE.INTEREST:
			
			var flat_bobber_destination = bobberGlobalPosition
			
			flat_bobber_destination.y = global_position.y
			
			velocity = global_position.direction_to(flat_bobber_destination) * fishSpeed
			
			rotate_towards_velocity(delta)
			
			if(couldBeBiting):
				
				if(PlayerStatGlobal.fishCurrentlyBiting.size() != PlayerStatGlobal.numFishPerBait):
					
					bitingHook = true
					
				Globals.disableOtherFishDetectionBox(self)
				
				couldBeBiting = false
				
				if(PlayerStatGlobal.fishCurrentlyBiting.find(self) == -1):
					
					PlayerStatGlobal.fishCurrentlyBiting.append(self)
					
				biting.emit()#received by the bobber
				
				Globals.stop_other_fish_interest(self)
				
			if(bitingHook):
				
				if(Globals.currentBobber != null):
					
					global_position.y += Globals.currentBobber.deltaGlobalPosition.y
				
				rotation.x = lerp_angle(rotation.x, atan2(-Vector3.UP.x, -Vector3.UP.z), delta)
				
			else:
				rotate_towards_velocity(delta)
	#print("fish state is " + str(currentState))
	debugSphere.global_position = next_path_position
	
	move_and_slide()

#when fish is added to the scene tree, it chooses from a list of it's minigames

func calculate_difficulty():
	pass

func choose_minigame():
	
	var randobj = RandomNumberGenerator.new()
	
	var resource_list = minigamePreloader.get_resource_list()
	
	var chosen_game_index = randobj.randi_range(0, resource_list.size() - 1)
	print("Minigame scene vvv")
	return minigamePreloader.get_resource(resource_list[chosen_game_index])
	print("Minigame scene ^^^")
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
	
	print(movement_target)
	navAgent.set_target_position(movement_target)

func _on_idle_timer_timeout():
	
	set_movement_target(get_random_position())
	currentState = FISHSTATE.MOVE

func poll_interest(bait_key):
	
	var randnum = RandomNumberGenerator.new()
	
	var poll_result = randnum.randi_range(1, 100)
	
	print("Interest result is " + str(poll_result))
	
	var target := 0
	
	if(BAIT_INTEREST_DICT.has(bait_key)):
		
		target = BAIT_INTEREST_DICT[bait_key]
	
	if(poll_result <= target && isInterested == false):
		
		currentState = FISHSTATE.INTEREST
		

func _on_detection_box_area_entered(area):
	
	if(!area.owner.polling_interest.is_connected(poll_interest)):
		
		area.owner.polling_interest.connect(poll_interest)
		
	if(!area.owner.in_the_bite_zone.is_connected(check_if_biting)):
		
		area.owner.in_the_bite_zone.connect(check_if_biting)
		
	bobberGlobalPosition = area.owner.global_position
	
	print("Fish entered bobber bait range")

func _on_detection_box_area_exited(area):
	
	print("Disconnecting signal")
	
	if(area.name != "BobberBiteZone"):#change to non magic string
		
		area.get_parent().disconnect("polling_interest", poll_interest)
		
	couldBeBiting = false
		
	if(bitingHook):
		
		if(Globals.currentBobber.is_queued_for_deletion()):
			
			#Globals.store_fish_for_respawn()
			#queue_free()#Replace with minigame transition code
			print("Minigame before calling leveltransition is " + str(minigame))
			LevelTransition.minigameDifficulty = currentDifficulty
			LevelTransition.transition_to_minigame(minigame, self)
		
func resize():
	
	var randnum := RandomNumberGenerator.new()
	
	var scale_max := scale / 2.0
	
	var new_scale := randnum.randf_range(-scale_max.x, scale_max.x)
	
	var difficulty_range = absf(new_scale) + scale_max.x
	
	currentDifficulty = LevelTransition.calculate_difficulty(difficulty_range, scale_max.x * 2)
	
	print("Current difficulty is " + str(currentDifficulty))
	
	if(wasRespawned):
		
		return scale
	
	return scale + Vector3(new_scale, new_scale, new_scale)
	
func rotate_towards_velocity(delta):
	
	rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * angularAcceleration)# Thank you youtube guy holy goddamn
	
func check_if_biting(areaID):
	#This runs if the fish is found in the inner bobber cylinder regardless of interest
	#If they are interested, this will trigger the biting in the INTEREST state
	
	print("Check if biting..")
	couldBeBiting = true
	biteZoneID = areaID
	print(biteZoneID)

func entered_swim_zone():
	
	currentState = FISHSTATE.MOVE
	
	if(Globals.currentWaterPlane.entered_swim_zone.is_connected(entered_swim_zone)):
		
		Globals.currentWaterPlane.disconnect("entered_swim_zone", entered_swim_zone)



func _on_tree_exiting():
	
	Globals.listOfSpawnedFish.pop_at(Globals.listOfSpawnedFish.find(self))
	#Globals.store_fish_for_respawn()
	
func _on_tree_exited():
	
	PlayerStatGlobal.fishCurrentlyBiting.pop_at(PlayerStatGlobal.fishCurrentlyBiting.find(self))
	
	Globals.enableAllFishDetectionBox()
