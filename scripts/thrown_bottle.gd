extends Node3D

@export var pathFollow : PathFollow3D

@export var bottleMesh : MeshInstance3D

@export var lowerRotSpeed : float

@export var upperRotSpeed : float

var timeCalcNumerator := 60.0

var rotationSpeed := 0.0

var timeToCompleteArc = 0.0
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
	
	bottleMesh.rotation_degrees.x += rotationSpeed

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
