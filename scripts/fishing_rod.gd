extends Node3D

@export var animationPlayer : AnimationPlayer

@export var bobberResources : ResourcePreloader

signal cast_ended

var cameraViewPort := get_viewport()

var mousePos := Vector2.ZERO

var camera : Camera3D

var bobberList = null

var bobberIndex = 0

var destinationPosition = null

@export var castCharge := 0.0

var depthOutput = 0.0

var lastCastBobber = null

var frame_count = 0

var castAngle = 9.2 #Z angle for casting, used for dynamically interrupting cast for less power (future implementation as of 4/30)

var tween : Tween

var alreadyTweened := false

var distanceOfWater := 0.0 
enum STATE {
	MOVING,
	CASTING
}

var currentState = STATE.MOVING

func _ready():
	
	bobberList = bobberResources.get_resource_list()
	cameraViewPort = get_viewport()
	camera = cameraViewPort.get_camera_3d()
	call_deferred("get_water_height")
func _physics_process(delta):
	
	var frame_rate = 1/delta
	
	#var cast_increment_num = 1.0
	mousePos = cameraViewPort.get_mouse_position()
	
	var clamped_mouse = Vector2(mousePos.x, clamp(mousePos.y, 30, 470))
	
	match currentState:
		STATE.MOVING:
			#print(global_position)
			if Input.is_action_pressed("cast"):
				var increment_value = distanceOfWater / frame_rate
				if(!alreadyTweened):
					
					tween = get_tree().create_tween()
					print("tween created")
					tween.tween_property(self, "rotation_degrees:z", castAngle * 3, 1.0)
					alreadyTweened = true
					
				castCharge += increment_value
				castCharge = clampf(castCharge, 0.0, distanceOfWater)
				print("rotation_degrees.z is " +str(rotation_degrees.z))
				print("Cast charge is " +str(castCharge))
				print("Current rotation is " + str(rotation_degrees))
				
			if Input.is_action_just_released("cast"):
				
				if(tween):
					
					print("Will kill tween " + str(tween))
					tween.kill()
					alreadyTweened = false
				
				tween = get_tree().create_tween()
				tween.tween_property(self, "rotation_degrees:z", 0.0, 0.1)
				var depth_input = camera.project_position(clamped_mouse, 8)
		
				depthOutput = screen_point_to_ray(depth_input)
				depthOutput = clampf(depthOutput, 3.0, 8.0)
				
				if(depthOutput):
					
					destinationPosition = camera.project_position(clamped_mouse, depthOutput)
					destinationPosition = Vector3(castCharge, global_position.y, global_position.z)
					create_bobber_from_anim()
					currentState = STATE.CASTING
				castCharge = 0.0
			var movement_position = camera.project_position(mousePos, 2)
			
			global_position.z = movement_position.z
			
		STATE.CASTING:
			
			if Input.is_action_just_released("cast"):
				
				lastCastBobber.queue_free()
				currentState = STATE.MOVING
				depthOutput = false
	
func create_bobber(index, destination):
	
	var bobberResource = bobberList[index]
	bobberResource = bobberResources.get_resource(bobberResource)
	bobberResource = bobberResource.instantiate()
	get_parent().add_child(bobberResource)
	bobberResource.global_position = destination
	lastCastBobber = bobberResource
	
func create_bobber_from_anim():
	if(depthOutput):
		
		create_bobber(bobberIndex,destinationPosition)

func screen_point_to_ray(depth_input):
	
	var ray_parameters := PhysicsRayQueryParameters3D.create(camera.global_position, depth_input)
	var space_state = get_world_3d().direct_space_state
	var ray_dict = space_state.intersect_ray(ray_parameters)
	if (ray_dict):
		var intersect_position = Vector2(ray_dict.position.x, ray_dict.position.z)#dict assumes global
		var camera2dPosition = Vector2(camera.global_position.x, camera.global_position.z)#so we need global position
	
		return camera2dPosition.distance_to(intersect_position)
	return false

func get_water_height():
	distanceOfWater = get_parent().navAreaDimensions.x
