class_name IdleState

extends State

func _ready():
	set_physics_process(false)
	state = BasicFish.FISHSTATE.IDLE
