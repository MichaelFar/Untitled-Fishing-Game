extends Node

var currentWaterDimension := Vector2.ZERO

var currentLevel = null

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
