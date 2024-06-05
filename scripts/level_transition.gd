extends Node


#func _process(delta):
	#if (Input.is_action_just_released("ui_select")):
		#if(Globals.currentLevel.process_mode == PROCESS_MODE_INHERIT):# == 0
			#
			#Globals.currentLevel.process_mode = PROCESS_MODE_DISABLED
			#
		#else:
			#
			#Globals.currentLevel.process_mode = PROCESS_MODE_INHERIT
