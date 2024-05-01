extends Node3D

var navAreaDimensions : Vector2

@export var water_mesh: MeshInstance3D

func _ready():
	pass
	
func set_nav_area_dimensions():
	navAreaDimensions = water_mesh.mesh.size
