extends StaticBody2D

@export var nextFrameLocation : Marker2D

var occupied := false

var originalColor = null

func _ready():
	
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)
	originalColor = modulate

func _on_area_2d_area_entered(area):
	print("entered")
	if area.owner.is_in_group("draggable"):
		occupied = true


func _on_area_2d_area_exited(area):
	if area.owner.is_in_group("draggable"):
		occupied = false
