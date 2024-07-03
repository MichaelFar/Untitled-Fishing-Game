extends Node3D

@export var animationPlayer : AnimationPlayer

func _ready():
	
	random_hide_children()
	
	animationPlayer.play("hit")
	
func random_hide_children():
	
	var randobj = RandomNumberGenerator.new()
	
	var randIndex = randobj.randi_range(0, get_children().size() - 2)
	
	var children = get_children()
	
	for i in range(get_children().size() - 1):
		
		if i != randIndex:
			
			get_children()[i].visible = false
