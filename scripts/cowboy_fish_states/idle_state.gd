class_name IdleState

extends State

func _ready():
	
	set_physics_process(false)
	
	state = BasicFish.FISHSTATE.IDLE
	
	set_interrupt_state(0)
	
func enter_state():
	
	if(actor.idleTimer.is_stopped()):
				
		actor.idleTimer.start()
		
func _on_idle_timer_timeout():
	
	actor.set_movement_target(actor.get_random_position())
	actor.stateMachine.change_state(nextState)
#set_movement_target(get_random_position())
#currentState = FISHSTATE.MOVE
