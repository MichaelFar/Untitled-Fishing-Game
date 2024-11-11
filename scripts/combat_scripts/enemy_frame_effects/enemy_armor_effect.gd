extends FrameEffect

class_name EnemyArmorEffect

func _ready():

	value = 2 
	description = "Defends against" + str(2) + "damage"

func execute_effect():
	CombatGlobal.enemyObjects[0].add_to_armor(value)
