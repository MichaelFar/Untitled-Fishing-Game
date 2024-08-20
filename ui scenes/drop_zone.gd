extends StaticBody2D

@export var nextFrameLocation : Marker2D

@export var frameStart : Marker2D

@export var frameEnd : Marker2D

@export var colorRect : ColorRect

var frameHeight : int

var occupied := false

var originalColor = null

func _ready():
	
	frameHeight = colorRect.size.y
	
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	originalColor = modulate

func _on_area_2d_area_entered(area):
	
	print("entered")
	
	if area.owner.is_in_group("draggable"):
		
		modulate = Color(Color.REBECCA_PURPLE, 1)
			
func _on_area_2d_area_exited(area):
	
	if area.owner.is_in_group("draggable"):
		
		if(area.owner.slotted_in_frame.is_connected(set_occupied)):
			
			area.owner.slotted_in_frame.disconnect(set_occupied)
			
		modulate = originalColor
		#occupied = false

func set_occupied(value : bool, signal_source):
	occupied = value
	#if(!occupied):
		#signal_source.slotted_in_frame.disconnect(set_occupied)
