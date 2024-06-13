extends Node3D

var cursor = load("res://textures/crosshair_red_large.png")

@export var camera : Camera3D
func _ready():
	
	Input.set_custom_mouse_cursor(cursor)

func _physics_process(delta):
	
	if(Input.is_action_just_pressed("cast")): #Left click
		
		shoot_gun()

func shoot_gun():
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = true
	var raycast_result = space.intersect_ray(ray_query)
	print(raycast_result)
