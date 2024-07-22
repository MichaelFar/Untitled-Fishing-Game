class_name IdleState

extends State

func _ready():
	
	set_physics_process(false)
	
	state = BasicFish.FISHSTATE.IDLE

func enter_state():
	
	if(actor.idleTimer.is_stopped()):
				
		actor.idleTimer.start()

#set_movement_target(get_random_position())
#currentState = FISHSTATE.MOVE
