extends MeshInstance3D

var startPoint = Vector3.ZERO #For the purposes of a fishing line this should not change
var endPoint = Vector3.ZERO

var objectToFollow = null

var hasCast := false

func _process(delta):
	
	if(hasCast):
		var modified_position = to_local(objectToFollow.topOfBobber.global_position)
		
		draw_line(modified_position)#+ Vector3(0,objectToFollow.position.y,0))
		
func draw_line(new_end_point : Vector3):
	clear_line()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	mesh.surface_add_vertex(startPoint)
	endPoint = new_end_point
	
	mesh.surface_add_vertex(endPoint)
	mesh.surface_end()

func clear_line():
	mesh.clear_surfaces()

	

