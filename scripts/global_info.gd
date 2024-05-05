extends Node

var currentWaterDimension := Vector2.ZERO

var currentLevel = null

signal calculated_water_mesh_origin

func emit_water_mesh_signal(waterMeshOrigin : Vector2):
	
	calculated_water_mesh_origin.emit(waterMeshOrigin)
