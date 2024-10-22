extends FrameEffect
class_name PlayerArmorEffect


func ready():
	
	value = 2

func execute_effect():
	
	CombatGlobal.playerObjects[0].add_to_armor(value)
