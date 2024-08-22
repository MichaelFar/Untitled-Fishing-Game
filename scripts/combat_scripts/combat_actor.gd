extends Node

class_name CombatActor

@export var maxHP := 5

@export var armor := 0

@export var framesResources : ResourcePreloader

var currentHP := maxHP

signal healed_hp
signal taken_damage

func add_to_HP(hp_change : int):
	
	currentHP = clamp(currentHP + hp_change, 0, maxHP)
	
func add_to_armor(armor_change : int):
	
	armor = armor + armor_change

func take_damage(damage : int):
	
	taken_damage.emit()
	
	var temp_damage := damage
	
	temp_damage = clamp(temp_damage - armor, 0, temp_damage)
	
	armor = clamp(armor - damage, 0, armor)
	
	add_to_HP(temp_damage)
