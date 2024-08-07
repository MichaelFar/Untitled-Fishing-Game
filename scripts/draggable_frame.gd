extends Node2D

var should_be_dragged := false

var inside_drop_zone := false

var body_ref = null

var offset : Vector2

var initialPosition : Vector2

func _ready():
	pass

func _process(delta):
	if (should_be_dragged):
		
		if(Input.is_action_just_pressed("cast")):
			initialPosition = global_position
			offset = get_global_mouse_position() - global_position
			UiGlobal.dragging_frame = true
			
		if(Input.is_action_pressed("cast")):
			
			global_position = get_global_mouse_position() - offset
		
		elif(Input.is_action_just_released("cast")):
			
			UiGlobal.dragging_frame = false
			var tween = get_tree().create_tween()
			
			if(inside_drop_zone):
				tween.tween_property(self, "position", 
				body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
				
			else:
				tween.tween_property(self, "global_position", 
				initialPosition, 0.2).set_ease(Tween.EASE_OUT)
			
func _on_area_2d_mouse_entered():
	
	if (!UiGlobal.dragging_frame):
		
		should_be_dragged = true
		scale = Vector2(1.05, 1.05)
		
	#print("Mouse entered")
	
func _on_area_2d_mouse_exited():
	
	if (!UiGlobal.dragging_frame):
		
		should_be_dragged = false
		scale = Vector2(1.0, 1.0)
		
	#print("Mouse exited")

func _on_area_2d_body_entered(body):
	if body.is_in_group("droppable"):
		
		inside_drop_zone = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body_ref = body
		
	#print("Body entered")
	
func _on_area_2d_body_exited(body):
	
	if(body_ref == body):
		
		inside_drop_zone = false
		body.modulate = body.originalColor
		
	if(body.is_in_group("droppable")):
		
		body.modulate = body.originalColor
		
	#print("Body exited")
