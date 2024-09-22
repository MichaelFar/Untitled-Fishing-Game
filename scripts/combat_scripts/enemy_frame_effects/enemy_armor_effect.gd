extends FrameEffect

class_name EnemyArmorEffect

func execute_effect():
	CombatGlobal.enemyObjects[0].add_to_armor(2)
