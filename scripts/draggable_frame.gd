extends CharacterBody2D

@export var frameSize : int

@export var visualContainer : Node2D

@export var texture : Sprite2D

var should_be_dragged := false

var insideDropZone := false

var body_ref = null

var bodyRefArray : Array

var offset : Vector2

var initialPosition : Vector2

var frameHeight : int

signal slotted_in_frame

func _ready():
	
	frameHeight = texture.texture.get_height() * scale.x

func _process(delta):
	
	if (should_be_dragged):
		
		if(Input.is_action_just_pressed("cast")):
			
			initialPosition = global_position
			offset = get_global_mouse_position() - global_position
			UiGlobal.dragging_frame = true
			slotted_in_frame.emit(false)
			#bodyRefArray = []
		if(Input.is_action_pressed("cast")):
			
			global_position = get_global_mouse_position() - offset
		
		elif(Input.is_action_just_released("cast")):
			
			UiGlobal.dragging_frame = false
			var tween = get_tree().create_tween()
			tween.finished.connect(emit_frame_occupied)
			
			var proper_position = get_proper_position()
			
			#print("bodyRefArray size is " + str(bodyRefArray.size()))
			visualContainer.z_index = 0
			if(bodyRefArray.size() != frameSize):
				
				tween.tween_property(self, "global_position", 
				initialPosition, 0.2).set_ease(Tween.EASE_OUT)
				#print("bodyRefArray size is not framesize")
			elif(insideDropZone):
				
				tween.tween_property(self, "position", 
				proper_position, 0.2).set_ease(Tween.EASE_OUT)
				#print("bodyRefArray size is framesize and insideDropZone is true")
			else:
				
				tween.tween_property(self, "global_position", 
				initialPosition, 0.2).set_ease(Tween.EASE_OUT)
				#print("bodyRefArray size is framesize and insideDropZone is false")
func _on_area_2d_mouse_entered():
	
	if (!UiGlobal.dragging_frame):
		
		should_be_dragged = true
		visualContainer.scale = Vector2(1.05, 1.05)
		visualContainer.z_index = 1
		
func _on_area_2d_mouse_exited():
	
	if (!UiGlobal.dragging_frame):
		
		should_be_dragged = false
		visualContainer.scale = Vector2(1.0, 1.0)
		
func _on_area_2d_body_entered(body):
	
	if body.is_in_group("droppable"):
		print("body is droppable")
		if(!body.occupied):
			#print("body not occupied")
			slotted_in_frame.connect(body.set_occupied)
			insideDropZone = true
			body_ref = body
			bodyRefArray.append(body_ref)
			print(bodyRefArray)
			
func _on_area_2d_body_exited(body):
	
	if(body_ref == body):
		pass
		#insideDropZone = false
		
	if(body.is_in_group("droppable")):
		if(!body.occupied):
			#print("Popping body ref")
			bodyRefArray.pop_at(bodyRefArray.find(body))
	
func emit_frame_occupied():
	
	await get_tree().physics_frame
	
	slotted_in_frame.emit(true)

func get_proper_position():
	
	var averaged_position : Vector2
	
	for i in bodyRefArray:
	
		averaged_position += i.global_position
		
	averaged_position = averaged_position / float(bodyRefArray.size())
	
	return averaged_position

func create_effect():#Called when frame becomes active
	print("Hello")
