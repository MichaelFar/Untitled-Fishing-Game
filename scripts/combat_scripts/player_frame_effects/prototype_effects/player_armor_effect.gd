extends FrameEffect
class_name PlayerArmorEffect

func execute_effect():
	
	CombatGlobal.playerObjects[0].add_to_armor(2)
