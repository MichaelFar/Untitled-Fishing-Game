extends Node

var currentWaterDimension := Vector2.ZERO

var currentLevel = null

@onready var gravity : float =  ProjectSettings.get_setting("physics/3d/default_gravity")

signal calculated_water_mesh_origin

func emit_water_mesh_signal(waterMeshOrigin : Vector2):
	
	calculated_water_mesh_origin.emit(waterMeshOrigin)
