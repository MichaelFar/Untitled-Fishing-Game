extends Node

class_name CombatActor

@export var healthBar : ProgressBar

@export var healthLabel : RichTextLabel

@export var armorBar : ProgressBar

@export var armorLabel : RichTextLabel

@export var framesResources : ResourcePreloader

@export var track : Node2D #Do not assign this in the EnemyCombatActor scene, assign in track_timeline


@export var maxHP := 5 :
	set(value):
		maxHP = value
		update_text()

@export var armor := 0 :
	set(value):
		armor = value
		update_text()
		
var currentHP := maxHP:
	set(value):
		currentHP = value
		update_text()		
signal healed_hp

signal taken_damage

func add_to_HP(hp_change : int):
	
	currentHP = clamp(currentHP + hp_change, 0, maxHP)
	
func add_to_armor(armor_change : int):
	
	armor = armor + armor_change
	
func take_damage(damage : int):
	
	await get_tree().process_frame
	
	taken_damage.emit()
	
	var temp_damage := damage
	
	temp_damage = clamp(temp_damage - armor, 0, temp_damage)
	
	armor = clamp(armor - damage, 0, armor)
	print("Damage taken is " + str(temp_damage))
	add_to_HP(-temp_damage)
	
func place_ui():
	
	healthBar.position = track.global_position
	
	healthBar.position.y -= track.frameHeight / 4
	healthBar.position.x -= track.frameHeight * 2.0

func update_text():
	
	healthBar.value = currentHP
	healthLabel.text = "[center]" + str(currentHP) + "[/center]"
	armorBar.value = armor
	armorLabel.text = "[center]" + str(armor) + "[/center]"

func reset_armor():
	
	armor = 0
	
func set_health_to_full():
	
	currentHP = maxHP
