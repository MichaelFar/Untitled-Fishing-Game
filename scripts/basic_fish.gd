class_name BasicFish

extends CharacterBody3D

@export var animationPlayer : AnimationPlayer

@export var navAgent : NavigationAgent3D

@export var idleTimer : Timer

@export var debugSphere := MeshInstance3D

@export var detectionBox : Area3D

@export var navDetectionBox : Area3D

@export var minigamePreloader : ResourcePreloader

@export var stateMachine : FiniteStateMachine

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

var inBiteRange := false

var biteZoneID = null

var wasRespawned := false

var minigame = null

var currentDifficulty := LevelTransition.DIFFICULTY.EASY

#var bobberReference := load("bobber.gd")

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
	pass
	#set_movement_target(get_random_position())
	#currentState = FISHSTATE.MOVE

func poll_interest(bait_key, bobber):
	
	var randnum = RandomNumberGenerator.new()
	
	var poll_result = randnum.randi_range(1, 100)
	
	#print("Interest result is " + str(poll_result))
	
	var target := 0
	
	if(BAIT_INTEREST_DICT.has(bait_key)):
		
		target = BAIT_INTEREST_DICT[bait_key]
	
	if(poll_result <= target && isInterested == false):
		
		#currentState = FISHSTATE.INTEREST
		isInterested = true
		stateMachine.change_state(stateMachine.state.interruptState)

func _on_detection_box_area_entered(area):
	
	var bobber = area.owner
	
	if(!bobber.polling_interest.is_connected(poll_interest)):
		
		bobber.polling_interest.connect(poll_interest)
		
	if(!bobber.in_the_bite_zone.is_connected(check_if_biting)):
		
		bobber.in_the_bite_zone.connect(check_if_biting)
		
	bobberGlobalPosition = bobber.global_position
	
	print("Fish entered bobber bait range")

func _on_detection_box_area_exited(area):
	
	print("Disconnecting signal")
	
	#if(area.name != "BobberBiteZone"):#change to non magic string
	#if(area.owner != bobberReference):#BAD does not do what the above does
	area.get_parent().disconnect("polling_interest", poll_interest)
		
	#couldBeBiting = false
		
	if(bitingHook):
		
		if(Globals.currentBobber.is_queued_for_deletion()):
			
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
	inBiteRange = true
	biteZoneID = areaID
	print(biteZoneID)

func entered_swim_zone():
	
	stateMachine.change_state(stateMachine.get_next_state())
	
	if(Globals.currentWaterPlane.entered_swim_zone.is_connected(entered_swim_zone)):
		
		Globals.currentWaterPlane.disconnect("entered_swim_zone", entered_swim_zone)

func _on_tree_exiting():
	
	Globals.listOfSpawnedFish.pop_at(Globals.listOfSpawnedFish.find(self))
	#Globals.store_fish_for_respawn()
	
func _on_tree_exited():
	
	PlayerStatGlobal.fishCurrentlyBiting.pop_at(PlayerStatGlobal.fishCurrentlyBiting.find(self))
	
	Globals.enableAllFishDetectionBox()
