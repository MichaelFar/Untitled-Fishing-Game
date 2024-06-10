extends Node

#This global node handles transitioning between the current fishing pond scene and a fish's respective minigame
#Certain functions are contained in global_info, like storing fish in a dict to be reloaded

func transition_to_minigame(packed_minigame_scene, fish_to_ignore):
	Globals.store_fish_for_respawn(fish_to_ignore)
	
	get_tree().change_scene_to_packed.bind(packed_minigame_scene).call_deferred()

func transition_to_fishing_game(packed_main_fishing_game):
	
	
	
	#Globals.listOfSpawnedFish = []
	
	get_tree().change_scene_to_packed.bind(packed_main_fishing_game).call_deferred()
	
	Globals.pondHasBeenReloaded = true
	
func _process(delta):
	
	if(Input.is_action_just_released("ui_select")):
		
		transition_to_fishing_game(FishingPondsStorage.get_pond_resource(0))
