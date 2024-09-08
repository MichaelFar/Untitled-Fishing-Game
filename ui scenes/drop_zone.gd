extends StaticBody2D

@export var nextFrameLocation : Marker2D

@export var frameStart : Marker2D

@export var frameEnd : Marker2D

@export var colorRect : ColorRect

@export var staticCollider : CollisionShape2D

@export var area : Area2D

var frameHeight : int

var occupied := false

var originalColor = null

func _ready():
	
	frameHeight = colorRect.size.y
	
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	originalColor = modulate

func _on_area_2d_area_entered(area):
	
	if area.owner.is_in_group("draggable"):
		
		modulate = Color(Color.REBECCA_PURPLE, 1)
		
func _on_area_2d_area_exited(area):
	
	if area.owner.is_in_group("draggable"):
		
		if(area.owner.slotted_in_frame.is_connected(set_occupied)):
			
			print("Disconnecting slotted_in_frame")
			
			area.owner.slotted_in_frame.disconnect(set_occupied)
			
		if(!occupied):
			
			modulate = originalColor
			
func set_occupied(value : bool):
	
	occupied = value
	
	if(occupied):
		
		modulate = Color(Color.REBECCA_PURPLE, 1)
	else:
		modulate = originalColor
	

func toggle_collision_bodies():
	
	staticCollider.disabled = !staticCollider.disabled
	area.monitoring = !area.monitoring
