extends Node3D

@export var shard_speed := 3.0

@export var hitScene : PackedScene

var rigidChildList := []

func _ready():
	
	rigidChildList = get_rigid_children()
	orient_rigid_bodies()
	apply_force_to_pieces()
	print("global_position of shattered bottle is " + str(global_position))
	
func spawn_hit_effect():
	
	var hit_scene = hitScene
	
	hit_scene = hit_scene.instantiate()
	
	add_child(hit_scene)
	
	hit_scene.global_position = global_position

func get_rigid_children():
	
	var rigid_child_list = []
	
	for i in get_children():
		if i is RigidBody3D:
			rigid_child_list.append(i)
			
	return rigid_child_list

func orient_rigid_bodies():
	
	for i in rigidChildList:
		
		for y in i.get_children():
			if y is MeshInstance3D:
				y.top_level = true
				i.global_position = y.global_position
				y.top_level = false

func apply_force_to_pieces():
	var randobj := RandomNumberGenerator.new()
	
	
	for i : RigidBody3D in rigidChildList:
		
		#randobj.randomize()
		
		var random_direction = Vector3(randobj.randf_range(-1.0,1.0)
		,randobj.randf_range(-1.0,1.0),
		i.global_position.z * shard_speed)
		
		i.apply_impulse(random_direction)
	
