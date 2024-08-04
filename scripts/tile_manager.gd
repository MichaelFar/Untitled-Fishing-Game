extends Node3D

@export var tilePreloader : ResourcePreloader

@export var numTiles := 0

var tileInstances := []

func _ready():
	
	spawn_tiles(get_random_tiles(get_tile_resources(), numTiles))
	
func get_tile_resources(): #Returns list of unloaded tile resources
	
	var tile_resource_list := []
	
	for i in tilePreloader.get_resource_list():
		
		tile_resource_list.append(tilePreloader.get_resource(i))
	
	return tile_resource_list

func get_random_tiles(total_tile_resource_list : Array, num_tiles : int):
	
	var to_be_loaded_resource_list := []
	
	var randobj = RandomNumberGenerator.new()
	
	var rand_index := 0
	
	print("Number of tiles is " + str(num_tiles))
	
	for i in range(num_tiles):
		
		rand_index = randobj.randi_range(0, total_tile_resource_list.size() - 1)
		
		to_be_loaded_resource_list.append(total_tile_resource_list[rand_index])
	
		print(i)
		
	return to_be_loaded_resource_list
	
func spawn_tiles(to_be_loaded_resource_list : Array):
	
	var previous_child = null
	
	for i in to_be_loaded_resource_list:
		
		var tile_instance = i.instantiate()
		
		add_child(tile_instance)
		
		if(previous_child == null):
			
			previous_child = tile_instance
			print("Previous child is null")
			
		else:
			
			tile_instance.global_position = previous_child.endPoint.global_position
			print("Position of previous child is " + str(tile_instance.global_position))
			previous_child = tile_instance
			tileInstances.append(previous_child)
		
		
