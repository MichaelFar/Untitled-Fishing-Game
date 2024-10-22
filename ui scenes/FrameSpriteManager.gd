extends Node2D

@export var sprite : Sprite2D

@export var resourcePreloader : ResourcePreloader

@export var toolTipLabel : Label

@export var toolTipContainer : TextureRect

func _ready():
	
	instantiate_nine_patch()
	set_tooltip_visible(false)
func instantiate_nine_patch():
	
	var resource_list = resourcePreloader.get_resource_list()
	
	var rand_obj = RandomNumberGenerator.new()
	
	var rand_index = rand_obj.randi_range(0, resource_list.size() - 1)
	
	sprite.texture = resourcePreloader.get_resource(resource_list[rand_index])

func set_tooltip_visible(new_value : bool):
	
	toolTipContainer.visible = new_value
