class_name MoveState
#Classes are used less for inheritance purposes and more for node exposure in the editor

extends State

func _ready():
	set_physics_process(false)
	state = BasicFish.FISHSTATE.MOVE
	
