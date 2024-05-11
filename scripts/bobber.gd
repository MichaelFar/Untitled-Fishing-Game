extends Node3D

@export var animationPlayer : AnimationPlayer
@export var topOfBobber : Marker3D
var directionCoefficient = 1.0
var currentXZPosition : Vector2

func _ready():
	start_bobbing()
	
func start_bobbing():
	animationPlayer.play("bobbing")
	create_y_tween()



func create_y_tween():
	
	
	directionCoefficient *= -1
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", directionCoefficient * 0.1, 1)
	
	tween.finished.connect(create_y_tween)
	

	
