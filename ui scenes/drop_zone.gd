extends StaticBody2D

@export var nextFrameLocation : Marker2D

var occupied := false

var originalColor = null

#Seeing as we will want to use the occupied boolean to tell if a frame is occupied,
#this check should probably happen when the action is dragged over the frame
#meaning we likely shouldn't also set the occupied status at that time
#this will work for now
#we should also consider that an occupied frame shouldn't be set to unoccupied if a different frame is dragged over it

func _ready():
	
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	originalColor = modulate

func _on_area_2d_area_entered(area):
	print("entered")
	if area.owner.is_in_group("draggable"):
		pass
		#area.owner.slotted_in_frame.connect(set_occupied)


func _on_area_2d_area_exited(area):
	if area.owner.is_in_group("draggable"):
		if(area.owner.slotted_in_frame.is_connected(set_occupied)):
			area.owner.slotted_in_frame.disconnect(set_occupied)
		
		#occupied = false

func set_occupied(value : bool, signal_source):
	occupied = value
	#if(!occupied):
		#signal_source.slotted_in_frame.disconnect(set_occupied)
