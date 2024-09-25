extends Node

var enemyObjects : Array[CombatActor] #Enemies during combat

var playerObjects : Array[CombatActor]#player party

var trackTimeline = null


func _process(delta: float) -> void:
	
	if (Input.is_action_just_released("Debug")):
		
		for i in playerObjects:
			i.set_health_to_full()
		for i in enemyObjects:
			i.set_health_to_full()

func round_end_cleanup():
	
	for i in enemyObjects:
		
		i.clear_track_frames()
		i.repopulate_track()
		i.reset_armor()
		
	for i in playerObjects:
		
		i.reset_armor()
		
