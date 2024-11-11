extends FrameEffect

class_name PlayerAttackEffect

func _ready():
	
	value = 2
	description = "Deal " + str(value) + " damage"

func execute_effect():
	#print("Effect executed")
	CombatGlobal.enemyObjects[0].take_damage(value)
