extends StaticBody2D

@export var nextFrameLocation : Marker2D

@export var frameStart : Marker2D

@export var frameEnd : Marker2D

@export var colorRect : ColorRect

@export var staticCollider : CollisionShape2D

@export var area : Area2D

@export var hoverColor : Color

@export var bubbleParticle : PackedScene

var frameHeight : int

var occupied := false

var originalColor = null

func _ready():
	
	frameHeight = colorRect.size.y
	
	#modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	originalColor = colorRect.color

func _on_area_2d_area_entered(area):
	
	if area.owner.is_in_group("draggable"):
		
		colorRect.color = hoverColor
		
func _on_area_2d_area_exited(area):
	
	if area.owner != null:#If something is freed while inside an area, the signal will trigger for exiting, this means that we need to check null
		
		if area.owner.is_in_group("draggable"):
			
			if(area.owner.slotted_in_frame.is_connected(set_occupied)):
				
				print("Disconnecting slotted_in_frame")
				
				area.owner.slotted_in_frame.disconnect(set_occupied)
				
			if(!occupied):
				
				colorRect.color = originalColor
			
func set_occupied(value : bool):
	
	occupied = value
	
	if(occupied):
		
		colorRect.color = hoverColor
	else:
		spawn_bubble_particle()
		colorRect.color = originalColor
	
		
	
	
	
func spawn_bubble_particle():
	var bubble_instance = bubbleParticle.instantiate()
	add_child(bubble_instance)
	bubble_instance.global_position = global_position
	bubble_instance.one_shot = true

func toggle_collision_bodies():
	
	staticCollider.disabled = !staticCollider.disabled
	area.monitoring = !area.monitoring
