extends Node3D

var rotationOfBottle := Vector3.ZERO

var positionOfBottle := Vector3.ZERO

var brokenBottleScene := preload("res://modelScenes/shattered_bottle.tscn")

func _ready():
	
	pass
	
func _physics_process(delta):
	
	pass
	
func handle_raycast_result(raycast_result : Dictionary):
	
	raycast_result.collider.owner.spawn_broken_bottle()
	
	raycast_result.collider.owner.queue_free()

func _on_area_3d_area_entered(area):
	
	area.get_parent().queue_free()
	print("Deleting shard")
