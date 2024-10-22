extends FrameEffect

class_name EnemyDamageEffect


func _ready():
	print("Enemy attack effect has entered the tree")
	value = 2

func execute_effect():
	
	print("Executing damage effect")
	CombatGlobal.playerObjects[0].take_damage(value)
