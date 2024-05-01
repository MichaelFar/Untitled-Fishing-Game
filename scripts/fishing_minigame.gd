extends Node3D

var navAreaDimensions : Vector2 #x is "height" of the water plane in 2d terms (away from rod)

@export var water_mesh: MeshInstance3D

func _ready():
	set_nav_area_dimensions()
	
func set_nav_area_dimensions():
	navAreaDimensions = water_mesh.mesh.size 
