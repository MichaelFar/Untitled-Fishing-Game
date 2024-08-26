extends CombatActor

class_name PlayerCombatActor

func _ready() -> void:
	
	CombatGlobal.playerObjects.append(self)
