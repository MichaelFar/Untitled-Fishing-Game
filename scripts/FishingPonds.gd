extends Node3D

@export var PondResources : ResourcePreloader

var pondResourceList = []

func _ready():
	
	pondResourceList = PondResources.get_resource_list()

func get_pond_resource(index : int):
	
	return PondResources.get_resource(pondResourceList[index])
