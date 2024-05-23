extends Node

var currentWaterDimension := Vector2.ZERO

var currentLevel = null

var currentBobber = null

var listOfSpawnedFish := []

@onready var gravity : float =  ProjectSettings.get_setting("physics/3d/default_gravity")

var waterMeshOrigin = Vector3.ZERO

signal calculated_water_mesh_origin

enum BAITS {
	LEECHES,
	GRUBS,
	WORMS
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
