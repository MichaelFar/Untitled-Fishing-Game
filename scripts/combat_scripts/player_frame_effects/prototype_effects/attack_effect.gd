extends FrameEffect

class_name PlayerAttackEffect

func execute_effect():
	#print("Effect executed")
	CombatGlobal.enemyObjects[0].take_damage(2)
