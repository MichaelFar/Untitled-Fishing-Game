extends RigidBody3D

@export var animationPlayer : AnimationPlayer
@export var topOfBobber : Marker3D
@export var interestTimer : Timer

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = Globals.gravity

var currentBait = Globals.BAITS.GRUBS #This will be changed to be whatever the player has decided to equip

var directionCoefficient = 1.0
var currentXZPosition : Vector2

var submerged := false

signal has_hit_water

signal polling_interest

signal in_the_bite_zone

func _ready():
	interestTimer.timeout.connect(emit_polling)

func _physics_process(delta):
	
	submerged = false
	var depth = 0.0 - global_position.y
	if depth > 0:
		submerged = true
		apply_force(Vector3.UP * float_force * gravity * depth)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag 
		
func create_y_tween():
	
	directionCoefficient *= -1
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", directionCoefficient * 0.1, 1)
	
	tween.finished.connect(create_y_tween)
	
func _on_area_3d_area_entered(area):
	interestTimer.start()

func emit_polling():
	
	polling_interest.emit(currentBait)


func _on_bobber_bite_zone_area_entered(area):
	in_the_bite_zone.emit()
