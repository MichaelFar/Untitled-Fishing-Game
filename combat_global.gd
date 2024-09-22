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
