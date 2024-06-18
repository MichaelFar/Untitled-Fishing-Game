extends Node3D

@export var pathFollow : PathFollow3D

@export var path3D : Path3D

@export var bottleMesh : Node3D

@export var lowerRotSpeed : float

@export var upperRotSpeed : float

@export var midPoint : Marker3D

var timeCalcNumerator := 60.0

var rotationSpeed := 0.0

var timeToCompleteArc = 0.0

var brokenBottleScene := preload("res://modelScenes/shattered_bottle.tscn")

var parent = null

func _ready():
	
	#random_tilt()
	
	rotationSpeed = random_rotation_speed()
	timeCalcNumerator = upperRotSpeed * 2.0
	timeToCompleteArc = timeCalcNumerator / rotationSpeed #((rotationSpeed + (upperRotSpeed - lowerRotSpeed) / 2.0) - lowerRotSpeed) / 5.0
	
	#timeToCompleteArc = clampf(timeToCompleteArc, 2.0, 4.0)
	
	tween_path_follow()
	print("Time to complete arc is " + str(timeToCompleteArc))
	print("Chosen rotation speed is " + str(rotationSpeed))
	
func _physics_process(delta):
	
	if(bottleMesh != null):
		bottleMesh.rotation_degrees.x += rotationSpeed

func set_path_points(mid_point : Vector3, end_point : Vector3):
	
	print(mid_point)
	print(end_point)
	
	path3D.curve.set_point_position(1, mid_point)
	path3D.curve.set_point_position(2, end_point)

func random_tilt():
	
	var randobj = RandomNumberGenerator.new()
	
	var randX = randobj.randf_range(0.0, 360.0)
	
	var randZ = randobj.randf_range(0.0, 360.0)
	
	bottleMesh.rotation_degrees.x = randX
	bottleMesh.rotation_degrees.z = randZ

func random_rotation_speed():
	
	var randobj = RandomNumberGenerator.new()
	return randobj.randi_range(lowerRotSpeed, upperRotSpeed)
	
func tween_path_follow():
	
	await get_tree().physics_frame
	var tween = get_tree().create_tween()
	
	tween.tween_property(pathFollow, "progress_ratio" , 1.0, timeToCompleteArc)

func spawn_broken_bottle():
	
	var broken_bottle_instance = brokenBottleScene.instantiate()
	parent.add_child(broken_bottle_instance)
	broken_bottle_instance.global_position = bottleMesh.global_position
	broken_bottle_instance.rotation = bottleMesh.rotation
	print("Spawned broken bottle")


func _on_shoot_zone_input_event(camera, event, position, normal, shape_idx):
	
	if(event.is_action_pressed("cast")):
		
		spawn_broken_bottle()
		queue_free()
		print("Bottle was clicked")
