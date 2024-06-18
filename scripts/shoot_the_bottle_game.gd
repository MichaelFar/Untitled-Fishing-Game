extends Node3D

@export var markerContainer : Node3D

@export var thrownObjectResources : ResourcePreloader

@export var throwTimer : Timer

@export var numThrows := 0

var currentThrows := 0

var rotationOfBottle := Vector3.ZERO

var positionOfBottle := Vector3.ZERO

var brokenBottleScene := preload("res://modelScenes/shattered_bottle.tscn")

var markerList = []

func _ready():
	
	markerList = markerContainer.get_children()
	throwTimer.start()
	
	
func _physics_process(delta):
	
	pass

func calculate_start_point():
	
	var randobj = RandomNumberGenerator.new()
	
	var x_point = randobj.randf_range(markerList[0].global_position.x, markerList[1].global_position.x)
	
	var start_point = Vector3(x_point, markerList[0].global_position.y,markerList[0].global_position.z)
	
	print("Start point is " + str(start_point))
	
	return start_point

func calculate_end_point():
	
	var randobj = RandomNumberGenerator.new()
	
	var x_point = randobj.randf_range(markerList[2].global_position.x, markerList[3].global_position.x)
	
	var end_point = Vector3(x_point, markerList[2].global_position.y,markerList[3].global_position.z)
	
	print("End point is " + str(end_point))
	
	return end_point
	
func calculate_mid_point(point_one, point_two):
	
	var mid_point = Vector3((point_one.x + point_two.x) / 2.0, 0.0 ,(point_one.z + point_two.z) / 2.0)
	
	print("Mid point is " + str(mid_point))
	
	return mid_point

func _on_area_3d_area_entered(area):
	
	area.get_parent().queue_free()
	print("Deleting shard")

func spawn_bottle():
	
	currentThrows += 1
	
	var thrown_bottle = thrownObjectResources.get_resource_list()[0]
	
	thrown_bottle = thrownObjectResources.get_resource(thrown_bottle)
	
	thrown_bottle = thrown_bottle.instantiate()
	
	var start_point = calculate_start_point()
	var end_point = calculate_end_point() * -1.0
	end_point.y *= -1.0
	add_child(thrown_bottle)
	
	thrown_bottle.parent = self
	var mid_point = calculate_mid_point(start_point, end_point)
	mid_point.y = thrown_bottle.midPoint.global_position.y
	print("Mid point is " + str(mid_point))
	thrown_bottle.global_position = start_point
	thrown_bottle.set_path_points(mid_point, end_point)


func _on_bottle_throw_timer_timeout():
	if(currentThrows < numThrows):
		spawn_bottle.call_deferred()
