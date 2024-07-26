class_name SpawnMoveState
extends State

func _ready():
	
	set_physics_process(false)
	
	state = BasicFish.FISHSTATE.SPAWNMOVE
	
func enter_state() -> void:
	
	set_physics_process(true)

func exit_state():
	
	set_physics_process(false)
	actor.velocity = Vector3.ZERO
	print("Reached nav box")
	
	actor.currentState = actor.FISHSTATE.IDLE
	
func _physics_process(delta):
	
	var modified_spawn_destination = Vector3(actor.global_position.x, actor.spawnDestination.y, actor.global_position.z)
	
	actor.velocity = actor.global_position.direction_to(modified_spawn_destination) * actor.fishSpeed

func _on_destination_end_area_entered(area):
	print("Actor is " + str(actor))
	print("actor.statemachine is " +str(actor.stateMachine))
	if(area == actor.navDetectionBox):
		actor.stateMachine.change_state(nextState)
		
