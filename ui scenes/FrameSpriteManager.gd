extends Node2D

@export var sprite : Sprite2D

@export var resourcePreloader : ResourcePreloader


func _ready():
	randomize_sprite_texture()
	
func randomize_sprite_texture():
	
	var resource_list = resourcePreloader.get_resource_list()
	
	var rand_obj = RandomNumberGenerator.new()
	
	var rand_index = rand_obj.randi_range(0, resource_list.size() - 1)
	
	sprite.texture = resourcePreloader.get_resource(resource_list[rand_index])
