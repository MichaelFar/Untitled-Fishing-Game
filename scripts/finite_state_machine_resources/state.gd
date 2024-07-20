class_name State
extends Node

signal state_finished

@export var state : BasicFish.FISHSTATE

@export var actor : BasicFish #The node that states affect



func enter_state() -> void: 
	print("State entered " + str(state))
	
func exit_state() -> void:
	pass
