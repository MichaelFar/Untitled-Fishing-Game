extends Node3D

@export var PondResources : ResourcePreloader

var currentPond : PackedScene

var pondResourceList = []

func _ready():
	
	pondResourceList = PondResources.get_resource_list()
	currentPond = get_pond_resource(0)

func get_pond_resource(index : int):
	
	return PondResources.get_resource(pondResourceList[index])
