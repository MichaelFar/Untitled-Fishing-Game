extends Node3D

@export var animationPlayer : AnimationPlayer

@export var navAgent : NavigationAgent3D

@export var fish_speed := 0.5

func _physics_process(delta):
	pass


func get_random_position():
	
	var randnum = RandomNumberGenerator.new()
	var chosen_position := Vector2.ZERO
	chosen_position.x = randnum.randf_range(0.0,Globals.currentWaterDimension.x)
	chosen_position.y = randnum.randf_range(0.0,Globals.currentWaterDimension.y)
	return chosen_position
