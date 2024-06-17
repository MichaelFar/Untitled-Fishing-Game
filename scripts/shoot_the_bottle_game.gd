extends Node3D

@export var markerContainer : Node3D

@export var thrownObjectResources : ResourcePreloader

var rotationOfBottle := Vector3.ZERO

var positionOfBottle := Vector3.ZERO

var brokenBottleScene := preload("res://modelScenes/shattered_bottle.tscn")

var markerList = []

func _ready():
	
	markerList = markerContainer.get_children()
	
	spawn_bottle()
	
func _physics_process(delta):
	
	pass

func calculate_start_point():
	
	var randobj = RandomNumberGenerator.new()
	
	var x_point = randobj.randf_range(markerList[0].position.x, markerList[1].position.x)
	
	var start_point = Vector3(x_point, markerList[0].position.y,markerList[0].position.z)
	
	return start_point

func calculate_end_point():
	
	var randobj = RandomNumberGenerator.new()
	
	var x_point = randobj.randf_range(markerList[2].position.x, markerList[3].position.x)
	
	var end_point = Vector3(x_point, markerList[2].position.y,markerList[3].position.z)
	
	return end_point
	
func calculate_mid_point(point_one, point_two):
	
	return Vector3((point_one.x + point_two.x) / 2.0, 0.0 ,(point_one.z + point_two.z) / 2.0)

func handle_raycast_result(raycast_result : Dictionary, count):
	print("Time to shoot is " + str(count))
	pass
	#raycast_result.collider.owner.spawn_broken_bottle()
	#
	#raycast_result.collider.owner.queue_free()

func _on_area_3d_area_entered(area):
	
	area.get_parent().queue_free()
	print("Deleting shard")


func spawn_bottle():
	
	var thrown_bottle = thrownObjectResources.get_resource_list()[0]
	
	thrown_bottle = thrownObjectResources.get_resource(thrown_bottle)
	
	thrown_bottle = thrown_bottle.instantiate()
	
	var start_point = calculate_start_point()
	var end_point = calculate_end_point()
	
	
	add_child(thrown_bottle)
	var mid_point = calculate_mid_point(start_point, end_point)
	mid_point.y = thrown_bottle.midPoint.position.y
	thrown_bottle.position = start_point
	thrown_bottle.set_path_points(mid_point, end_point)
