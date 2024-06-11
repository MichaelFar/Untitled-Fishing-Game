extends Node3D

var cursor = load("res://textures/crosshair_red_large.png")

func _ready():
	
	Input.set_custom_mouse_cursor(cursor)

func _physics_process(delta):
	
	var mousePos = get_viewport().get_mouse_position()
	
	
