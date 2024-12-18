extends CharacterBody2D

@export var frameSize : int

@export var visualContainer : Node2D

@export var texture : Sprite2D

@export var frameEffectResources : ResourcePreloader

@export var mouseInteractableAreaArray : Array[Area2D]

@onready var originalIconScale = texture.scale

@export var frameSpriteManager : Node2D

var effectObject : FrameEffect

var effectValue : int

var combatActor : CombatActor

var debugStringMessage = "I am not in a bubble"

var can_be_dragged := false

var can_be_dragged_override := false

var body_ref = null

var bodyRefArray : Array

var offset : Vector2

var initialPosition : Vector2

var frameHeight : int

signal slotted_in_frame

signal dragging_frame

signal triggered_effect

signal mouse_hover_for_tooltip

func _ready():
	
	frameHeight = texture.texture.get_height() * scale.x
	wibble_the_icon()
	mouseInteractableAreaArray[1].input_event.connect(_on_area_2d_2_input_event)
	print("drag override is " + str(can_be_dragged_override))
	tree_exiting.connect(on_queue_free)
	effectObject = create_effect()
	
	if(effectObject != null):
		
		effectValue = effectObject.value
		
		frameSpriteManager.description = effectObject.description
		print("Frame description is " + frameSpriteManager.description)
		
	if(frameSpriteManager != null):
		mouse_hover_for_tooltip.connect(frameSpriteManager.set_tooltip_visible)
	
func _process(delta):
	
	if (can_be_dragged && UiGlobal.ableToDragFrame):
		
		if(Input.is_action_just_pressed("cast")):
			
			initialPosition = global_position
			offset = get_global_mouse_position() - global_position
			UiGlobal.dragging_frame = true
			slotted_in_frame.emit(false)
			mouse_hover_for_tooltip.emit(false)
			
		if(Input.is_action_pressed("cast") && UiGlobal.dragging_frame):
			
			global_position = get_global_mouse_position() - offset
		
		elif(Input.is_action_just_released("cast")):
			
			UiGlobal.dragging_frame = false
			var tween = get_tree().create_tween()
			tween.finished.connect(run_end_of_tween)
			UiGlobal.ableToDragFrame = false
			can_be_dragged = false
			var proper_position = get_proper_position()
			
			visualContainer.z_index = 0
			
			if(bodyRefArray.size() != frameSize):
				
				tween.tween_property(self, "global_position", 
				initialPosition, 0.2).set_ease(Tween.EASE_OUT)
				print("bodyRefArray size is not framesize and frame size is " + str(frameSize) + " while bodyRefArray is " + str(bodyRefArray.size()))
				
			else:
				
				tween.tween_property(self, "global_position", 
				proper_position, 0.2).set_ease(Tween.EASE_OUT)
				print("bodyRefArray size is framesize")

func create_tooltip_timer():
	
	var temp_lambda = func():
		
		mouse_hover_for_tooltip.emit(can_be_dragged && !UiGlobal.dragging_frame)
	
	get_tree().create_timer(0.2).timeout.connect(temp_lambda)
				
func _on_area_2d_mouse_entered():
	
	if (!UiGlobal.dragging_frame):
		print("Mouse entered frame")
		can_be_dragged = can_be_dragged_override
		create_tooltip_timer()
		#print("Can be dragged is " + str(can_be_dragged))
		visualContainer.scale = Vector2(1.05, 1.05)
		visualContainer.z_index = 1
		
func _on_area_2d_mouse_exited():
	
	if (!UiGlobal.dragging_frame):
		print("Mouse exited frame")
		can_be_dragged = false
		mouse_hover_for_tooltip.emit(can_be_dragged)
		visualContainer.scale = Vector2(1.0, 1.0)
		
func _on_area_2d_body_entered(body):
	
	if (body.is_in_group("frame_bubble")):
		
		print("Bubble entered drop zone")
		set_mouse_areas(false)
		
	if body.is_in_group("droppable"):
		
		print("body is droppable")
		
		if(!body.occupied):
			
			print("body not occupied")
			
			slotted_in_frame.connect(body.set_occupied)
			
			body_ref = body
			bodyRefArray.append(body_ref)
			print(str(bodyRefArray) + debugStringMessage)
			
	
func _on_area_2d_body_exited(body):
	
	if (body.is_in_group("frame_bubble")):
		print("Bubble exited drop zone")
		set_mouse_areas(true)
	
	if(body.is_in_group("droppable")):
		if(!body.occupied):
			#print("Popping body ref")
			bodyRefArray.pop_at(bodyRefArray.find(body))
			
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
			
			triggered_effect.connect(effect_instance.execute_effect)
			
			print(effect_instance)
			
			return effect_instance

func set_mouse_areas(new_value : bool):
	
	for i in mouseInteractableAreaArray:
		
		i.input_pickable = new_value

func wibble_the_icon():
	
	var scene_tree_timer = get_tree().create_timer(0.1)
	
	var rand_obj = RandomNumberGenerator.new()
	
	scene_tree_timer.timeout.connect(wibble_the_icon)
	
	texture.scale.x = originalIconScale.x + rand_obj.randf_range(-originalIconScale.x * .05, originalIconScale.x * .05)
	texture.scale.y = originalIconScale.y + rand_obj.randf_range(-originalIconScale.y * .05, originalIconScale.y * .05)

func _on_area_2d_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	#viewport.push_input(event)
	if(!UiGlobal.dragging_frame):
		can_be_dragged = can_be_dragged_override

func on_queue_free():
	
	if(combatActor.listOfSpawnedFrames.has(self)):
		
		combatActor.listOfSpawnedFrames.pop_at(combatActor.listOfSpawnedFrames.find(self))
	
	if(combatActor.listOfSpawnedFrames.size() == 0):
		
		combatActor.out_of_frames.emit()
	
	UiGlobal.dragging_frame = false
	
	UiGlobal.ableToDragFrame = true
