class_name InterestState

extends State

func _ready():
	set_physics_process(false)
	state = BasicFish.FISHSTATE.INTEREST
