class_name FiniteStateMachine
extends Node

@export var state: State

func _ready():
	
	change_state(state)

func change_state(new_state : State):
	
	print("New state is " + str(new_state))
	
	if (state is State):
		
		state.exit_state()
		
	new_state.enter_state()
	
	state = new_state
	
func get_next_state():
	
	return state.nextState
