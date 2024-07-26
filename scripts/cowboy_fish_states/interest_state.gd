class_name InterestState

extends State

func _ready():
	set_physics_process(false)
	state = BasicFish.FISHSTATE.INTEREST

func enter_state():
	set_physics_process(true)

func _physics_process(delta):
	
	var flat_bobber_destination = actor.bobberGlobalPosition
			
	flat_bobber_destination.y = actor.global_position.y
	
	actor.velocity = actor.global_position.direction_to(flat_bobber_destination) * actor.fishSpeed
	
	actor.rotate_towards_velocity(delta)
	
	if(actor.couldBeBiting):
		
		if(PlayerStatGlobal.fishCurrentlyBiting.size() != PlayerStatGlobal.numFishPerBait):
			
			actor.bitingHook = true
			
		Globals.disableOtherFishDetectionBox(actor)
		
		actor.couldBeBiting = false
		
		if(PlayerStatGlobal.fishCurrentlyBiting.find(actor) == -1):
			
			PlayerStatGlobal.fishCurrentlyBiting.append(actor)
			
		actor.biting.emit()#received by the bobber
		
		Globals.stop_other_fish_interest(actor)
		
	if(actor.bitingHook):
		
		if(Globals.currentBobber != null):
			
			actor.global_position.y += Globals.currentBobber.deltaGlobalPosition.y
		
		actor.rotation.x = lerp_angle(actor.rotation.x, atan2(-Vector3.UP.x, -Vector3.UP.z), delta)
		
	else:
		
		actor.rotate_towards_velocity(delta)
	
	actor.move_and_slide()
