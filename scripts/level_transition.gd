extends Node

#This global node handles transitioning between the current fishing pond scene and a fish's respective minigame
#Certain functions are contained in global_info, like storing fish in a dict to be reloaded

var minigameDifficulty := DIFFICULTY.EASY

enum DIFFICULTY { #This set based on size of the fish
	EASY,
	MEDIUM,
	HARD
}



func transition_to_minigame(packed_minigame_scene, fish_to_ignore):
	Globals.store_fish_for_respawn(fish_to_ignore)
	
	get_tree().change_scene_to_packed.bind(packed_minigame_scene).call_deferred()

func transition_to_fishing_game(packed_main_fishing_game):
	
	Input.set_custom_mouse_cursor(null)
	get_tree().change_scene_to_packed.bind(packed_main_fishing_game).call_deferred()
	
	Globals.pondHasBeenReloaded = true
	

func calculate_difficulty(difficulty_num, max_difficulty_num):
	
	var enum_array : Array[DIFFICULTY] = [DIFFICULTY.EASY, DIFFICULTY.MEDIUM, DIFFICULTY.HARD]
	
	var enum_size = enum_array.size()
	print("enum array" + str(enum_array))
	
	max_difficulty_num = max_difficulty_num / enum_size
	print( "Difficulty num is " + str(difficulty_num))
	print( "Max difficulty num is " + str(max_difficulty_num))
	for i in range(enum_size):
		
		if(difficulty_num <= max_difficulty_num * (i + 1)):
			
			return enum_array[i]
			
	
