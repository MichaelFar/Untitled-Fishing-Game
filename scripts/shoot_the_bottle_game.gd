extends Node3D

@export var markerContainer : Node3D

@export var thrownObjectResources : ResourcePreloader

@export var throwTimer : Timer

@export var endGameTimer : Timer

@export var UIContainer : Control

@export var listOfPhrases : PackedStringArray

@export var listOfOutroPhrases : PackedStringArray

@export var numThrows := 0

var currentThrows := 0

var rotationOfBottle := Vector3.ZERO

var positionOfBottle := Vector3.ZERO

var brokenBottleScene := preload("res://modelScenes/shattered_bottle.tscn")

var markerList = []

var score := 0

var difficulty := LevelTransition.DIFFICULTY.EASY

func _ready():
	
	markerList = markerContainer.get_children()
	
	set_random_phrase()
	
	UIContainer.intro_phrase_done.connect(initiate_game)
	
func set_random_phrase():
	
	var randobj = RandomNumberGenerator.new()
	
	var rand_index = randobj.randi_range(0, listOfPhrases.size() - 1)
	
	UIContainer.introPhrase = listOfPhrases[rand_index]
	
	UIContainer.convert_phrase_to_list()

func calculate_start_point():
	
	var randobj = RandomNumberGenerator.new()
	
	var x_point = randobj.randf_range(markerList[0].global_position.x, markerList[1].global_position.x)
	
	var start_point = Vector3(x_point, markerList[0].global_position.y,markerList[0].global_position.z)
	
	print("Start point is " + str(start_point))
	
	return start_point

func calculate_end_point():
	
	var randobj = RandomNumberGenerator.new()
	
	var x_point = randobj.randf_range(markerList[2].global_position.x, markerList[3].global_position.x)
	
	var end_point = Vector3(x_point, markerList[2].global_position.y,markerList[3].global_position.z)
	
	print("End point is " + str(end_point))
	
	return end_point
	
func calculate_mid_point(point_one, point_two):
	
	var mid_point = Vector3((point_one.x + point_two.x) / 2.0, 0.0 ,(point_one.z + point_two.z) / 2.0)
	
	print("Mid point is " + str(mid_point))
	
	return mid_point

func _on_area_3d_area_entered(area):
	
	area.get_parent().queue_free()
	print("Deleting shard")

func calculate_angle_to_endpoint(start_point, end_point):
	
	start_point.y = lerp_angle(start_point.y, atan2(-end_point.x, -end_point.z), 1.0)
	return start_point.y
	
func spawn_bottle():
	
	currentThrows += 1
	
	var thrown_bottle = thrownObjectResources.get_resource_list()[0]
	
	thrown_bottle = thrownObjectResources.get_resource(thrown_bottle)
	
	thrown_bottle = thrown_bottle.instantiate()
	
	var start_point = calculate_start_point()
	var end_point = calculate_end_point() * -1.0
	var new_angle = calculate_angle_to_endpoint(start_point, end_point)
	#end_point.y *= -1.0
	add_child(thrown_bottle)
	
	thrown_bottle.parent = self
	thrown_bottle.global_position = start_point
	thrown_bottle.rotation.y = new_angle
	thrown_bottle.tree_exiting.connect(score_count)

func _on_bottle_throw_timer_timeout():
	
	if(currentThrows < numThrows):
		
		spawn_bottle.call_deferred()
		
	elif(!endGameTimer.time_left):#Replace this with code that is called when user clicks on the score screen
		
		endGameTimer.start()
		
		print("End game timer has started")


func _on_end_game_timer_timeout():
	#LevelTransition.transition_to_fishing_game(FishingPondsStorage.get_pond_resource(0))
	UIContainer.display_end("You hit " + str(score) + " / " + str(numThrows) + " bottles" + "\n\n\n" + calculate_outro_phrase())

func score_count():
	
	score += 1
	
func initiate_game():
	
	throwTimer.start()

func calculate_outro_phrase():
	
	var phrase_list = listOfOutroPhrases
	
	var num_tiers = phrase_list.size()
	
	var max_score = numThrows
	
	var player_score = score
	
	player_score = player_score / num_tiers
	
	player_score *= num_tiers
	
	max_score = max_score / num_tiers
	
	print("Player score " + str(player_score))
	print("Max score " + str(max_score))
	
	for i in range(num_tiers):
		
		if(player_score <= max_score * (i + 1)):
			return phrase_list[i]

