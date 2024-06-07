extends Node3D

@export var fishResources : ResourcePreloader
@export var spawnTimer : Timer
@export var spawnReferencePoint : Marker3D #fish will spawn below the water, with this serving as the y reference
@export var spawnDestination : Marker3D #fish will swim up upon spawning, this is where they are headed to
@export var fishNum = 5 #Number of fish who will spawn in total

var currentFishNum = 0

var fishList := []

var waterMeshOrigin = Vector2.ZERO

func _ready():
	
	Globals.calculated_water_mesh_origin.connect(set_water_mesh_origin)
	Globals.currentSpawnManager = self
	fish_resources_to_list()
	#spawnTimer.start()
	spawnTimer.timeout.connect(spawn_loop)
	await get_tree().physics_frame
	spawn_loop()
	print(fishResources.get_resource("basic_fish"))
	if(Globals.pondHasBeenReloaded):
		spawn_preexisting_fish()
#func _physics_process(delta):
	#
	#if(Input.is_action_just_released("ui_select")):
		#Globals.store_fish_for_respawn()
		#for i in Globals.listOfSpawnedFish:
			#
			#i.queue_free()
			#
		##await get_tree().physics_frame
		#
		#spawn_preexisting_fish()
		
func spawn_preexisting_fish():
	print("respawning fish")
	for i in Globals.fishStorageDict:
		
		if i % 2 == 0 || i == 0:
			
			var fish_instance = spawn_fish(Globals.fishStorageDict[i])
			print(fish_instance)
			print(Globals.fishStorageDict[i])
			await get_tree().physics_frame
			fish_instance.scale = Globals.fishStorageDict[i + 1]

func fish_resources_to_list():
	
	fishList = fishResources.get_resource_list()

func spawn_loop():
	
	currentFishNum = Globals.listOfSpawnedFish.size()
	
	if(currentFishNum < fishNum):
		
		spawnTimer.start()
		spawn_fish()
		
func set_water_mesh_origin(water_mesh_origin):
	
	waterMeshOrigin = water_mesh_origin

func spawn_fish(fish_packed_scene = null):
	
	var randnum = RandomNumberGenerator.new()
	var rand_index = randnum.randi_range(0, fishList.size() - 1)
	var fish_instance = fishResources.get_resource(fishList[rand_index])
	
	if(fish_packed_scene != null):
		
		fish_instance = fish_packed_scene
		
	fish_instance = fish_instance.instantiate()
	
	add_child(fish_instance)
	
	Globals.listOfSpawnedFish.append(fish_instance)
	Globals.currentWaterPlane.entered_swim_zone.connect(fish_instance.entered_swim_zone)
	
	fish_instance.spawnDestination = spawnDestination.global_position
	fish_instance.global_position = random_spawn_point()
	fish_instance.waterMeshOrigin = waterMeshOrigin
	fish_instance.fishResource = fishResources.get_resource(fishList[rand_index])
	
	return fish_instance
	
func random_spawn_point():
	
	var randnum = RandomNumberGenerator.new()
	var chosen_position := Vector3.ZERO
	#Remember, x and z are the "2d" coordinates not x and y. Y is always up
	print("water dimensions are origin is " + str(Globals.currentWaterDimension))
	chosen_position.x = randnum.randf_range(waterMeshOrigin.x, Globals.currentWaterDimension.x)
	chosen_position.z = randnum.randf_range(waterMeshOrigin.y, Globals.currentWaterDimension.y)
	chosen_position.y = spawnReferencePoint.global_position.y
	return chosen_position
	
