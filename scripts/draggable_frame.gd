extends CharacterBody2D

@export var frameSize : int

@export var visualContainer : Node2D

@export var texture : Sprite2D

@export var frameEffectResources : ResourcePreloader

@export var mouseInteractableAreaArray : Array[Area2D]

@onready var originalIconScale = texture.scale

var debugStringMessage = "I am not in a bubble"

var should_be_dragged := false

var insideDropZone := false

var body_ref = null

var bodyRefArray : Array

var offset : Vector2

var initialPosition : Vector2

var frameHeight : int

signal slotted_in_frame

signal dragging_frame

func _ready():
	
	frameHeight = texture.texture.get_height() * scale.x
	wibble_the_icon()
func _process(delta):
	
	if (should_be_dragged && UiGlobal.ableToDragFrame):
		
		if(Input.is_action_just_pressed("cast")):
			
			initialPosition = global_position
			offset = get_global_mouse_position() - global_position
			UiGlobal.dragging_frame = true
			slotted_in_frame.emit(false)
			#dragging_frame.emit(self, false)
			#bodyRefArray = []
		if(Input.is_action_pressed("cast") && UiGlobal.dragging_frame):
			
			global_position = get_global_mouse_position() - offset
		
		elif(Input.is_action_just_released("cast")):
			
			UiGlobal.dragging_frame = false
			var tween = get_tree().create_tween()
			tween.finished.connect(run_end_of_tween)
			UiGlobal.ableToDragFrame = false
			var proper_position = get_proper_position()
			
			#print("bodyRefArray size is " + str(bodyRefArray.size()))
			visualContainer.z_index = 0
			
			if(bodyRefArray.size() != frameSize):
				
				tween.tween_property(self, "global_position", 
				initialPosition, 0.2).set_ease(Tween.EASE_OUT)
				print("bodyRefArray size is not framesize and frame size is " + str(frameSize) + " while bodyRefArray is " + str(bodyRefArray.size()))
				
			elif(insideDropZone):
				
				tween.tween_property(self, "global_position", 
				proper_position, 0.2).set_ease(Tween.EASE_OUT)
				print("bodyRefArray size is framesize and insideDropZone is true")
				
			else:
				
				tween.tween_property(self, "global_position", 
				initialPosition, 0.2).set_ease(Tween.EASE_OUT)
				print("bodyRefArray size is framesize and insideDropZone is false")
				
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
			print("body not occupied")
			#for i in slotted_in_frame.get_connections():
				#slotted_in_frame.disconnect(i.callable)
			slotted_in_frame.connect(body.set_occupied)
			insideDropZone = true
			body_ref = body
			bodyRefArray.append(body_ref)
			print(str(bodyRefArray) + debugStringMessage)
	if (body.is_in_group("frame_bubble")):
		set_mouse_areas(false)
	
	
func _on_area_2d_body_exited(body):
		
	if(body.is_in_group("droppable")):
		if(!body.occupied):
			#print("Popping body ref")
			bodyRefArray.pop_at(bodyRefArray.find(body))
	if (body.is_in_group("frame_bubble")):
		set_mouse_areas(true)
func run_end_of_tween():
	
	await get_tree().physics_frame
	UiGlobal.ableToDragFrame = true
	slotted_in_frame.emit(true)

func get_proper_position():
	
	var averaged_position : Vector2
	
	for i in bodyRefArray:
		
		averaged_position += i.global_position
		
	averaged_position = averaged_position / float(bodyRefArray.size())
	
	return averaged_position

func create_effect():#Called when frame becomes active
	
	print("Effect triggered " + " and I am " + name)
	
	if(frameEffectResources.get_resource_list().size() > 0):
		
		for i in frameEffectResources.get_resource_list():
			
			var effect_resource = frameEffectResources.get_resource(i)
			
			var effect_instance = effect_resource.new()
			
			add_child(effect_instance)
			
			print(effect_instance)

func set_mouse_areas(new_value : bool):
	
	for i in mouseInteractableAreaArray:
		
		i.input_pickable = new_value

func wibble_the_icon():
	
	var scene_tree_timer = get_tree().create_timer(0.1)
	
	var rand_obj = RandomNumberGenerator.new()
	
	scene_tree_timer.timeout.connect(wibble_the_icon)
	
	texture.scale.x = originalIconScale.x + rand_obj.randf_range(-originalIconScale.x * .05, originalIconScale.x * .05)
	texture.scale.y = originalIconScale.y + rand_obj.randf_range(-originalIconScale.y * .05, originalIconScale.y * .05)
