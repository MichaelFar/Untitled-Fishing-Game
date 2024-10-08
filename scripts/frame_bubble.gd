extends CharacterBody2D

@export var bubbleSprite : Sprite2D

@export var bubbleDetails : Sprite2D

@export var bubbleParticleExplosion : PackedScene

@export var ClickArea : Area2D

var newFrame = null

var newFrameIconIndex := 0

var timeToComplete := .5

var scaleModifer := .1

func _ready():
	var rand_obj = RandomNumberGenerator.new()
	newFrameIconIndex = rand_obj.randi_range(0, CombatGlobal.playerObjects[0].listOfFrameResources.size() - 1)
	bubbleDetails.texture = CombatGlobal.playerObjects[0].listOfFrameIcons[newFrameIconIndex]
	#for i in CombatGlobal.playerObjects[0].listOfSpawnedFrames:
		#
		#i.set_mouse_areas(false)
	animate_bubble()
	
	tween_bubble_to_random_position()

func _physics_process(delta: float) -> void:
	bubbleDetails.scale = (bubbleSprite.scale / 8)
	bubbleSprite.rotation_degrees += 0.25
	
func tween_bubble_to_random_position():
	
	var rand_obj = RandomNumberGenerator.new()
	
	var view_port_rect = get_viewport_rect()
	
	var destination := Vector2(rand_obj.randf_range(0, view_port_rect.size.x), (rand_obj.randf_range(0, view_port_rect.size.y)))
	
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "global_position", destination, 5)# abs(destination.x - global_position.x) / 100.0 if destination.x - global_position.x > destination.y - global_position.y else abs(destination.y - global_position.y) / 100.0)
	
	tween.finished.connect(tween_bubble_to_random_position)

func animate_bubble():
	
	scaleModifer *= -1.0
	
	var xTween = get_tree().create_tween()
	
	var yTween = get_tree().create_tween()
	
	xTween.set_ease(Tween.EASE_OUT)
	
	yTween.set_ease(Tween.EASE_OUT)
	
	xTween.tween_property(bubbleSprite, "scale:x", 1.0 + scaleModifer, timeToComplete)
	
	yTween.tween_property(bubbleSprite, "scale:y", 1.0 + (-1.0 * scaleModifer), timeToComplete)
	
	xTween.finished.connect(animate_bubble)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	
	if(event.is_action_released("cast") && UiGlobal.bubble_can_pop):
		print("Clicked bubble")
		var bubble_instance : GPUParticles2D = bubbleParticleExplosion.instantiate()
		
		bubble_instance.one_shot = true
		Globals.currentLevel.add_child(bubble_instance)
		
		bubble_instance.global_position = global_position
		
		newFrame = CombatGlobal.playerObjects[0].add_new_frame_to_current_battle(newFrameIconIndex, global_position)
		newFrame.debugStringMessage = "I'm the bubble boy"
		CombatGlobal.trackTimeline.hasSpawnedBubble = false
		
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if (area.owner.is_in_group("draggable")):
		if(UiGlobal.dragging_frame):
			ClickArea.input_pickable = false
		

func _on_area_2d_area_exited(area: Area2D) -> void:
	if (area.owner.is_in_group("draggable")):
		if(!UiGlobal.dragging_frame):
			ClickArea.input_pickable = true
		
