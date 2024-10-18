extends Node2D

@export var mouthSprite : Sprite2D

@export var animationPlayer : AnimationPlayer

@export var eatParticle : PackedScene

var frameIsInMouth := false

var frameObject = null


func _ready():
	
	CombatGlobal.playerObjects[0].out_of_frames.connect(give_player_bubbles)

func give_player_bubbles():
	
	CombatGlobal.playerObjects[0].populate_track()
		
func _physics_process(delta: float) -> void:
	
	if(!animationPlayer.is_playing()):
		
		if(UiGlobal.dragging_frame):
			
			mouthSprite.frame = 1
			
		else:
			
			mouthSprite.frame = 0
	
	if(Input.is_action_just_released("cast") && frameIsInMouth):
		
		frameIsInMouth = false
		frameObject.queue_free()
		
		animationPlayer.play("eat")
		animationPlayer.queue("eat")
		animationPlayer.queue("eat")
		

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.owner.is_in_group("draggable"):
		
		frameIsInMouth = true
		frameObject = area.owner

func spawn_eat_particle():
	
	var particle_instance = eatParticle.instantiate()
	add_child(particle_instance)
	particle_instance.global_position = global_position
	particle_instance.one_shot = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	
	if(area.owner != null):
		if area.owner.is_in_group("draggable"):
			
			frameIsInMouth = false
			frameObject = null
