class_name MoveState
#Classes are used less for inheritance purposes and more for node exposure in the editor

extends State

func _ready():
	
	set_physics_process(false)
	
	state = BasicFish.FISHSTATE.MOVE
	
	set_interrupt_state(0)
	
func _physics_process(delta):
	
	var current_agent_position = actor.global_position
			
	var next_path_position = actor.navAgent.get_next_path_position()
	
	actor.velocity = current_agent_position.direction_to(next_path_position) * actor.fishSpeed
	
	if(next_path_position != actor.global_position):
		
		actor.rotation.x = lerp_angle(actor.rotation.x,atan2(-Vector3.FORWARD.x, -Vector3.FORWARD.z), delta * actor.angularAcceleration)
		
		actor.rotate_towards_velocity(delta)
		
	actor.debugSphere.global_position = next_path_position
	
	actor.move_and_slide()
func enter_state():
	set_physics_process(true)

func _on_destination_end_area_entered(area):
	actor.stateMachine.change_state(nextState)
