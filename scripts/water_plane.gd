extends MeshInstance3D

@export var navigationRegion := NavigationRegion3D

var navigationMesh = null

signal entered_swim_zone

func _ready():
	
	Globals.currentWaterPlane = self
	navigationMesh = navigationRegion.navigation_mesh
	print(navigationMesh.get_polygon_count())
	print(navigationMesh.get_polygon(0))
	print(navigationMesh.get_vertices())
	
func emitEnteredZone(area):
	entered_swim_zone.emit()
