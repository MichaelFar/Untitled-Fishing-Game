class_name InterruptState

extends State

func _ready() -> void:
	pass
	
func enter_state() -> void:
	actor.velocity = Vector3.ZERO
	actor.isInterested = true
	#set_movement_target(bobberGlobalPosition)
	actor.idleTimer.stop()
	actor.stateMachine.change_state(nextState)
