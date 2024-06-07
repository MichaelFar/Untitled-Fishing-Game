extends Node

#This global node handles transitioning between the current fishing pond scene and a fish's respective minigame
#Certain functions are contained in global_info, like storing fish in a dict to be reloaded

func transition_to_minigame(packed_minigame_scene):
	get_tree().change_scene_to_packed(packed_minigame_scene)

func transition_to_fishing_game(packed_main_fishing_game):
	print(packed_main_fishing_game)
	Globals.store_fish_for_respawn()
	await get_tree().physics_frame
	get_tree().change_scene_to_packed(packed_main_fishing_game)
	Globals.pondHasBeenReloaded = true
func _process(delta):
	
	if(Input.is_action_just_released("ui_select")):
		transition_to_fishing_game(FishingPondsStorage.get_pond_resource(0))
