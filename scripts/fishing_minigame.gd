extends Node3D

var navAreaDimensions : Vector2 #x is "height" of the water plane in 2d terms (away from rod)

@export var waterMesh: MeshInstance3D
#global coordinates for where the bottom left part of the water plane is
var waterMeshOrigin = Vector2.ZERO 

func _ready():
	
	navAreaDimensions = set_nav_area_dimensions()
	Globals.currentWaterDimension = navAreaDimensions
	Globals.currentLevel = self
	
func set_nav_area_dimensions():
	
	var xz_position = Vector2(waterMesh.global_position.x, waterMesh.global_position.z)
	waterMeshOrigin = (waterMesh.mesh.size / 2.0) - xz_position
	Globals.emit_water_mesh_signal(get_water_mesh_origin())
	print( "Origin of water mesh is " + str(waterMeshOrigin))
	return waterMesh.mesh.size 

func get_water_mesh_origin():
	return waterMeshOrigin
