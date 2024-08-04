class_name DungeonTile

extends Node3D

@export var endPoint : Marker3D

func get_endpoint_position():
	
	return endPoint.global_position
