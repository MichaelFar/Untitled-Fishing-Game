extends Node3D

@export var animationPlayer : AnimationPlayer
@export var topOfBobber : Marker3D
var directionCoefficient = 1.0
var currentXZPosition : Vector2

signal has_hit_water

func _ready():
	
	#start_bobbing()
	#print("bobber position at ready is " + str(global_position))
	has_hit_water.connect(start_bobbing)
	
func start_bobbing():
	
	animationPlayer.play("bobbing")
	create_y_tween()

func create_y_tween():
	#print("Bobber position is " + str(global_position))
	directionCoefficient *= -1
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", directionCoefficient * 0.1, 1)
	
	tween.finished.connect(create_y_tween)
	

