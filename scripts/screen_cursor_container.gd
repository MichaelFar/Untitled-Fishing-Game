extends Node3D

var cursor = load("res://textures/crosshair_red_large.png")

@export var camera : Camera3D

var hasShot := false

var frameCount = 0

func _ready():
	
	Input.set_custom_mouse_cursor(cursor)


