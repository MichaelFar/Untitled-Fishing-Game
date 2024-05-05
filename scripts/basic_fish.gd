extends CharacterBody3D

@export var animationPlayer : AnimationPlayer

@export var navAgent : NavigationAgent3D

@export var idleTimer : Timer

@export var fishSpeed := 0.5

var waterMeshOrigin = Vector2.ZERO

var chosenPosition := Vector3.ZERO

var currentState = FISHSTATE.MOVE

enum FISHSTATE {
	MOVE,
	IDLE,
}

func _ready():
	
	Globals.calculated_water_mesh_origin.connect(get_water_mesh_origin)
	call_deferred("actor_setup")

func _physics_process(delta):
	
	var current_agent_position: Vector3
	var next_path_position: Vector3
	
	match currentState:
		FISHSTATE.MOVE:
			current_agent_position = global_position
			next_path_position = navAgent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * fishSpeed
			print("Moving...")
			if(!animationPlayer.is_playing()):
				animationPlayer.play("looping_swim")
				
			if(next_path_position != global_position):
				look_at(next_path_position)
				
		FISHSTATE.IDLE:
			print("Idling...")
			if(idleTimer.is_stopped()):
				print("Timer starting...")
				#animationPlayer.pause()
				idleTimer.start()
	
	
	move_and_slide()

func get_water_mesh_origin(water_mesh_origin):
	
	waterMeshOrigin = water_mesh_origin
	print("Water mesh origin in basic_fish is " + str(waterMeshOrigin))
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(get_random_position())

func get_random_position():
	
	var randnum = RandomNumberGenerator.new()
	var chosen_position := Vector3.ZERO
	#Remember, x and z are the "2d" coordinates not x and y. Y is always up
	chosen_position.x = randnum.randf_range(waterMeshOrigin.x, Globals.currentWaterDimension.x)
	chosen_position.z = randnum.randf_range(waterMeshOrigin.y, Globals.currentWaterDimension.y)
	chosen_position.y = global_position.y
	return chosen_position
	
func set_movement_target(movement_target: Vector3):
	navAgent.set_target_position(movement_target)

func _on_idle_timer_timeout():
	set_movement_target(get_random_position())
	currentState = FISHSTATE.MOVE


func _on_navigation_agent_3d_target_reached():
	velocity = Vector3.ZERO
	currentState = FISHSTATE.IDLE
