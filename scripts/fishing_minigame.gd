extends Node3D

var navAreaDimensions : Vector2 #x is "height" of the water plane in 2d terms (away from rod)

@export var water_mesh: MeshInstance3D

func _ready():
	navAreaDimensions = set_nav_area_dimensions()
	Globals.currentWaterDimension = navAreaDimensions
func set_nav_area_dimensions():
	return water_mesh.mesh.size 
