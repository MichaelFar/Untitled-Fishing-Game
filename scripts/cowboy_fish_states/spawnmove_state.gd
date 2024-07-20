class_name SpawnMoveState
extends State

func _ready():
	set_physics_process(false)
	state = BasicFish.FISHSTATE.SPAWNMOVE

func enter_state() -> void:
	set_physics_process(true)
	
func _physics_process(delta):
	#actor.rotation.x = lerp_angle(actor.rotation.x, atan2(-Vector3.UP.x, -Vector3.UP.z), delta)
			
	var modified_spawn_destination = Vector3(actor.global_position.x, actor.spawnDestination.y, actor.global_position.z)
	
	actor.velocity = actor.global_position.direction_to(modified_spawn_destination) * actor.fishSpeed


func _on_destination_end_area_entered(area):
	if(area == actor.navDetectionBox):
		set_physics_process(false)
		actor.velocity = Vector3.ZERO
		print("Reached target")
		if(!actor.isInterested):
			
			actor.currentState = actor.FISHSTATE.IDLE
