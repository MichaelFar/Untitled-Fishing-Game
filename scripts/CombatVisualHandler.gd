extends Node2D

class_name VisualCombatActor

@export var playerSpriteArray : Array[Sprite2D] # Array of player sprites

@export var enemySpriteArray : Array[Sprite2D] # Array of enemy sprites

@export var nonCombatSpriteWibbleArray : Array[Node]

@export var hitParticle : PackedScene

var playerSpriteSizeArray : Array[Vector2]

var enemySpriteSizeArray : Array[Vector2]

var playerSpritePositionArray : Array[Vector2]

var enemySpritePositionArray : Array[Vector2]


func _ready():
	
	initialize_sprite_scales()
	initialize_wibble_effect()
	
	bob_the_player_sprites()
	bob_the_enemy_sprites(1.0)

func bob_the_player_sprites():
	
	for i in playerSpriteArray.size():
		bob_the_player_sprite_at_index(1.0, i)


func initialize_sprite_scales():
	
	for i in playerSpriteArray:
		
		playerSpriteSizeArray.append(i.scale)
		playerSpritePositionArray.append(i.global_position)
		
	for i in enemySpriteArray:
		
		enemySpriteSizeArray.append(i.scale)
		enemySpritePositionArray.append(i.global_position)
		
func initialize_wibble_effect():
	
	for i in nonCombatSpriteWibbleArray:
		
		wibble_the_icon(i, i.scale, 0.05)
	
	for i in playerSpriteArray.size():
		
		wibble_the_icon(playerSpriteArray[i], playerSpriteSizeArray[i], 0.015)
		
	for i in enemySpriteArray.size():
		
		wibble_the_icon(enemySpriteArray[i], enemySpriteSizeArray[i], 0.015)

func wibble_the_icon(sprite, original_size : Vector2, limit : float):
	
	var scene_tree_timer = get_tree().create_timer(0.1)
	
	var rand_obj = RandomNumberGenerator.new()
	
	var scale_coefficent := 0.05
	
	scene_tree_timer.timeout.connect(wibble_the_icon.bind(sprite, original_size, limit))
	
	sprite.scale.x = original_size.x + rand_obj.randf_range(-original_size.x * limit, original_size.x * limit)
	sprite.scale.y = original_size.y + rand_obj.randf_range(-original_size.y * limit, original_size.y * limit)

func bob_the_player_sprite_at_index(direction : float = 1.0, i = 0):
	
	var rand_obj = RandomNumberGenerator.new()
	
	var movement_limit = 20.0
		
	var sprite_object = playerSpriteArray[i]
	var bob_location = sprite_object.global_position.y + direction * rand_obj.randf_range(1.0, movement_limit)
	var tween = get_tree().create_tween()
	tween.set_ease(tween.EASE_IN)
	tween.tween_property(sprite_object, 
		"global_position:y", 
		clamp(sprite_object.global_position.y + direction * rand_obj.randf_range(1.0, movement_limit), 
		-movement_limit + playerSpritePositionArray[i].y, 
		movement_limit + playerSpritePositionArray[i].y), 
		playerSpritePositionArray[i].y / bob_location)
	tween.finished.connect(bob_the_player_sprite_at_index.bind(direction * -1.0), i) 
	
func bob_the_enemy_sprites(direction : float = 1.0):

	var rand_obj = RandomNumberGenerator.new()
	
	var movement_limit = 20.0
	
	for i in enemySpriteArray.size():
		
		var sprite_object = enemySpriteArray[i]
		
		var bob_location = sprite_object.global_position.y + direction * rand_obj.randf_range(1.0, movement_limit)
		
		var tween = get_tree().create_tween()
		tween.set_ease(tween.EASE_IN)
		tween.tween_property(sprite_object,
			"global_position:y", 
			clamp(sprite_object.global_position.y + direction * rand_obj.randf_range(1.0, movement_limit), 
			-movement_limit + enemySpritePositionArray[i].y, 
			movement_limit + enemySpritePositionArray[i].y),
			enemySpritePositionArray[i].y / bob_location)
		tween.finished.connect(bob_the_enemy_sprites.bind(direction * -1.0)) 

func instantiate_hit_particle(actor_target : CombatActor):
	
	print("Spawned effect")
	var rand_obj = RandomNumberGenerator.new()
	
	var particle_instance = hitParticle.instantiate()
	
	var affected_sprite = actor_target.representedSprite
	
	var sprite_rect_size = affected_sprite.region_rect.size
	
	Globals.currentLevel.add_child(particle_instance)
	
	particle_instance.one_shot = true
	
	particle_instance.global_position = affected_sprite.global_position#Vector2(rand_obj.randi_range((sprite_rect_size.x - affected_sprite.global_position.x),
	#(sprite_rect_size.x + affected_sprite.global_position.x))
	#, randi_range((sprite_rect_size.y - affected_sprite.global_position.y),
	#(sprite_rect_size.y + affected_sprite.global_position.y)))
	
