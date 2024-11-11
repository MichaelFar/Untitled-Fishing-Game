extends FrameEffect
class_name PlayerArmorEffect


func _ready():
	
	value = 2
	description = "Gain " + str(value) + " armor"
func execute_effect():
	
	CombatGlobal.playerObjects[0].add_to_armor(value)
