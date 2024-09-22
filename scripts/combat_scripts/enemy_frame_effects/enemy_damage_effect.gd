extends FrameEffect


func execute_effect():
	CombatGlobal.playerObjects[0].take_damage(2)
