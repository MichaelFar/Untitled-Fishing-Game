extends Node

class_name CombatActor

@export var maxHP := 5

@export var armor := 0

var currentHP := maxHP

func add_to_HP(hp_change : int):
	
	currentHP = clamp(currentHP + hp_change, 0, maxHP)
	
func add_to_armor(armor_change : int):
	
	pass
