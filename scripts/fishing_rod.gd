extends Node3D

signal cast_ended

@export var animationPlayer : AnimationPlayer

@export var bobberResources : ResourcePreloader

@export var bobberSpawnPoint : MeshInstance3D

@export var bobberDestination : Marker3D

@export var bezierArcPoint : MeshInstance3D #Debug representation of bezier arc point

@export var bezierDestination : MeshInstance3D#Debug representation of destination

@export var bobberPath : Path3D

@export var bobberFollow : PathFollow3D

@export var rodMesh : Node3D

@export var debugSphere : MeshInstance3D

@export var timeToCast = 1.0 #How long it takes to fully charge a cast in seconds

@export var castAngle = 9.2 #Z angle for casting, used for dynamically interrupting cast for less power (future implementation as of 4/30)

@export var bobberTravelSpeed = 0.01

var lineScene = preload("res://modelScenes/fishing_line.tscn")

var reticleResource = preload("res://modelScenes/bobber_reticle.tscn")

var arcAcceleration := 0.1

var arcTime := 3.0

var lineReference = null

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

var tweenDraw : Tween

var tweenCast : Tween

var alreadyTweened := false

var distanceOfWater := 0.0 

var bezierArcOriginalPosition = Vector3.ZERO

var hasCreatedBobber := false

enum STATE {
	MOVING, #Rod moves left and right
	CASTING,#Rod casts and the bobber is released
}

var baitsNum = {Globals.BAITS.LEECHES : 0, Globals.BAITS.GRUBS: 0, Globals.BAITS.WORMS : 0}

var currentState = STATE.MOVING

var numTweensCreated := 0

func _ready():
	
	bobberList = bobberResources.get_resource_list()
	cameraViewPort = get_viewport()
	camera = cameraViewPort.get_camera_3d()
	
	call_deferred("get_water_height")
	
func _physics_process(delta):
	
	var frame_rate = 1/delta
	var tweenCastIsRunning := false
	mousePos = cameraViewPort.get_mouse_position()
	
	var clamped_mouse = Vector2(mousePos.x, clamp(mousePos.y, 30, 470))
	
	match currentState:
		
		STATE.MOVING:
				
			if(tweenCast != null):
				#If the player casts again while the tweenCast is running,
				# unexpected behavior that leads to a crash occurs
				# We avoid this by checking if it's running before casting
				tweenCastIsRunning = tweenCast.is_running()
				
			if Input.is_action_pressed("cast") && !tweenCastIsRunning:
				
				var increment_value = bobberDestination.position.x / frame_rate
				
				if(!alreadyTweened):#Don't create a tween every frame
					numTweensCreated += 1
					reticleReference = create_reticle()
					#print("Reticle reference is " + str(reticleReference))
					
					tweenDraw = get_tree().create_tween()
					tweenDraw.tween_property(rodMesh, "rotation_degrees:z", castAngle * 3, timeToCast)
					alreadyTweened = true
					
				var reticle_position = Vector3(castCharge + bobberSpawnPoint.global_position.x, 0.1, global_position.z)
				
				castCharge += increment_value / timeToCast
				castCharge = clampf(castCharge, 0.0, bobberDestination.position.x)
				
				if(reticleReference != null):
					
					reticleReference.global_position = reticle_position
				
			if Input.is_action_just_released("cast"):
				
				if(tweenDraw):
					
					#print("tween killed: " + str(numTweensCreated))
					tweenDraw.kill()
					alreadyTweened = false
					
				destinationPosition = Vector3(castCharge + bobberSpawnPoint.position.x, bobberSpawnPoint.position.y, bobberSpawnPoint.position.z)
				
				tweenCast = get_tree().create_tween()
				
				tweenCast.tween_property(rodMesh, "rotation_degrees:z", 0.0, 0.1)
				tweenCast.finished.connect(create_bobber_from_anim)
				castCharge = 0.0
				
			var movement_position = camera.project_position(mousePos, 3.4)
			
			global_position.z = movement_position.z
		
		STATE.CASTING:
			
			if(reticleReference != null):
					#print("Reticle has been freed")
					reticleReference.queue_free()
					
			bobberPath.get_children()[0].progress_ratio += bobberTravelSpeed
			
			if(bobberPath.get_children()[0].progress_ratio >= .99):
				
				
				lastCastBobber.reparent(self)
				
			else:
				
				lastCastBobber.position = debugSphere.position
				
			if Input.is_action_just_released("cast"):
				
				lastCastBobber.queue_free()
				lineReference.queue_free()
				lineReference.clear_line()
				currentState = STATE.MOVING
				hasCreatedBobber = false
				bobberPath.get_children()[0].progress_ratio = 0.0
				
func create_reticle():
	
	var reticle_instance = reticleResource.instantiate()
	
	add_child(reticle_instance)
	reticle_instance.position.x = bobberSpawnPoint.position.x + Globals.currentWaterDimension.x
	return reticle_instance

func create_bobber(index):
	
	var bobber_resource = bobberList[index]
	bobber_resource = bobberResources.get_resource(bobber_resource)
	bobber_resource = bobber_resource.instantiate()
	bobberFollow.add_child(bobber_resource)
	destinationPosition.y = 0.0
	bobber_resource.global_position = bobberSpawnPoint.global_position
	lastCastBobber = bobber_resource
	lastCastBobber.rotation.z = 0
	await get_tree().physics_frame
	lineReference = create_line(bobber_resource)
	
func create_line(object_to_follow):
	
	var line_instance = lineScene.instantiate()
	line_instance.objectToFollow = object_to_follow
	line_instance.position = bobberSpawnPoint.position
	line_instance.spawnObject = bobberSpawnPoint
	add_child(line_instance)
	return line_instance
	
func create_bobber_from_anim():
	
	transition_to_cast()
	bezier_marker_placer()
	create_bobber(bobberIndex)
	
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

func bezier_marker_placer():
	
	var marker_position = bobberPath.curve.get_point_position(1)
	#print("reticle reference in bezier is " + str(reticleReference))
	marker_position.x = reticleReference.position.x / 2.0
	
	var final_position = marker_position
	final_position.x = reticleReference.position.x
	final_position.y = reticleReference.position.y
	
	bezierArcPoint.position = marker_position#Debug placements
	bezierDestination.position = final_position#Debug placements
	
	bobberPath.curve.set_point_position(0, bobberSpawnPoint.position)
	bobberPath.curve.set_point_position(1, marker_position)
	bobberPath.curve.set_point_position(2, final_position)
	
	return final_position
	
func transition_to_cast():
	currentState = STATE.CASTING
	
	
