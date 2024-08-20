class_name State
extends Node

signal state_finished

@export var nextState : State

@export var interruptStates : Array[State]

@export var actor : BasicFish #The node that states affect

var interruptState : State

func enter_state() -> void: 
	pass
	
func exit_state() -> void:
	pass

func set_interrupt_state(index : int):
	
	interruptState = interruptStates[index]

func get_interrupt_state():
	
	return interruptState
