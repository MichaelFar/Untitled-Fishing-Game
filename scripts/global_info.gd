extends Node

var currentWaterDimension := Vector2.ZERO

var currentWaterPlane = null

var currentLevel = null

var currentBobber = null

var currentSpawnManager = null

var listOfSpawnedFish := []

var fishStorageDict = {}

var pondHasBeenReloaded := false

@onready var gravity : float =  ProjectSettings.get_setting("physics/3d/default_gravity")

var waterMeshOrigin = Vector3.ZERO

signal calculated_water_mesh_origin

enum BAITS {#Currently test baits, can be anything, fish will check if they have a matching key when polling interest
	LEECHES,
	GRUBS,
	WORMS,
	TESTNOBAIT
}

func emit_water_mesh_signal(water_mesh_origin : Vector2):
	waterMeshOrigin = water_mesh_origin
	calculated_water_mesh_origin.emit(water_mesh_origin)

func disableOtherFishDetectionBox(fishID):
	for i in listOfSpawnedFish:
		if(i != fishID):
			print("Disabling fish " + str(i))
			i.detectionBox.monitoring = false
		
func enableAllFishDetectionBox():
	
	for i in listOfSpawnedFish:
		print("Enabling fish " + str(i))
		i.detectionBox.monitoring = true
		
func connectBitingSignal():
	
	if(currentBobber != null):
		for i in listOfSpawnedFish:
			if(!i.biting.is_connected(currentBobber.start_jolt_timer)):
				i.biting.connect(currentBobber.start_jolt_timer)
				
func stop_other_fish_interest(fish):
	for i in listOfSpawnedFish:
		if(i != fish):
			i.currentState = i.FISHSTATE.MOVE
			i.isInterested = false

func store_fish_for_respawn(): #Creates a dictionary of fish and their sizes, used for reloading the fishing minigame from
	var index = 0
	fishStorageDict = {}
	print("storing fish in dict for respawn")
	for i in listOfSpawnedFish:
		
		fishStorageDict[index] = i.fishResource
		fishStorageDict[index + 1] = i.scale
		index += 2
		
	print(fishStorageDict)
