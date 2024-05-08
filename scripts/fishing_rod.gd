extends Node3D

signal cast_ended

@export var animationPlayer : AnimationPlayer

@export var bobberResources : ResourcePreloader

@export var bobberSpawnPoint : Marker3D

@export var bobberDestination : Marker3D

@export var timeToCast = 1.0 #How long it takes to fully charge a cast in seconds


var castCharge := 0.0

var reticleReference = null

var cameraViewPort := get_viewport()

var mousePos := Vector2.ZERO

var camera : Camera3D

var bobberList = null

var bobberIndex = 0

var destinationPosition = null

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

@onready var reticleResource = preload("res://modelScenes/bobber_reticle.tscn")

func _ready():
	
	bobberList = bobberResources.get_resource_list()
	cameraViewPort = get_viewport()
	camera = cameraViewPort.get_camera_3d()
	call_deferred("get_water_height")
	
func _physics_process(delta):
	
	var frame_rate = 1/delta
	
	mousePos = cameraViewPort.get_mouse_position()
	
	var clamped_mouse = Vector2(mousePos.x, clamp(mousePos.y, 30, 470))
	
	match currentState:
		
		STATE.MOVING:
			
			if Input.is_action_pressed("cast"):
				
				var increment_value = bobberDestination.global_position.x / frame_rate
				
				if(!alreadyTweened):
					
					create_reticle()
					tween = get_tree().create_tween()
					tween.tween_property(self, "rotation_degrees:z", castAngle * 3, timeToCast)
					alreadyTweened = true
					
				var reticle_position = Vector3(castCharge + bobberSpawnPoint.global_position.x, 0.1, global_position.z)
				
				castCharge += increment_value / timeToCast
				castCharge = clampf(castCharge, 0.0, bobberDestination.global_position.x)
				
				if(reticleReference != null):
					
					reticleReference.global_position = reticle_position
				
			if Input.is_action_just_released("cast"):
				
				if(tween):
				
					tween.kill()
					alreadyTweened = false
					
				if(reticleReference != null):
					
					reticleReference.queue_free()
				
				destinationPosition = Vector3(castCharge + bobberSpawnPoint.global_position.x, global_position.y, global_position.z)
				#print(destinationPosition)
				tween = get_tree().create_tween()
				tween.tween_property(self, "rotation_degrees:z", 0.0, 0.1)
				create_bobber_from_anim()
				currentState = STATE.CASTING
				castCharge = 0.0
				
			var movement_position = camera.project_position(mousePos, 3.4)
			
			global_position.z = movement_position.z
			
		STATE.CASTING:
			
			if Input.is_action_just_released("cast"):
				
				lastCastBobber.queue_free()
				currentState = STATE.MOVING
				
func create_reticle():
	
	var reticle_instance = reticleResource.instantiate()
	reticleReference = reticle_instance
	get_parent().add_child(reticle_instance)
	reticle_instance.global_position = global_position

func create_bobber(index, destination):
	
	var bobber_resource = bobberList[index]
	bobber_resource = bobberResources.get_resource(bobber_resource)
	bobber_resource = bobber_resource.instantiate()
	get_parent().add_child(bobber_resource)
	bobber_resource.global_position = destination
	lastCastBobber = bobber_resource
	
func create_bobber_from_anim():
	
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
