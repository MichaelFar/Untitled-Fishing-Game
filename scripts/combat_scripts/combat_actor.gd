extends Node

class_name CombatActor

@export var healthBar : TextureProgressBar

@export var healthLabel : RichTextLabel

@export var armorBar : TextureProgressBar

@export var armorLabel : RichTextLabel

@export var framesResources : ResourcePreloader

@export var track : Node2D #Do not assign this in the EnemyCombatActor scene, assign in track_timeline

@export var visualCombatActor : VisualCombatActor

@export var representedSprite : Sprite2D

var listOfEmptyFrames = []

var listOfSpawnedFrames := []

@export var maxHP := 5 :
	set(value):
		maxHP = value
		update_text()
						
@export var armor := 0 :
	set(value):
		armor = value
		update_text()
						
var currentHP := maxHP :
	set(value):
		currentHP = value
		update_text()
						
signal healed_hp

signal taken_damage

signal blocked_damage

func add_to_HP(hp_change : int):
	
	currentHP = clamp(currentHP + hp_change, 0, maxHP)
	
func add_to_armor(armor_change : int):
	
	armor = armor + armor_change
	
func take_damage(damage : int):
	
	await get_tree().process_frame
	
	#taken_damage.emit()
	
	var temp_damage := damage
	
	temp_damage = clamp(temp_damage - armor, 0, temp_damage)
	
	armor = clamp(armor - damage, 0, armor)
	
	if(temp_damage > 0):
		
		taken_damage.emit()
		
	else:
		
		blocked_damage.emit()
		
	print("Damage taken is " + str(temp_damage))
	
	add_to_HP(-temp_damage)
	
func place_ui():
	
	healthBar.position = track.global_position
	
	healthBar.position.y -= track.frameHeight / 4
	healthBar.position.x -= track.frameHeight * 2.0
	
	healthBar.max_value = maxHP
	
func update_text():
	var tween = get_tree().create_tween()
	
	tween.tween_property(healthBar, "value", currentHP, 0.1)
	
	healthLabel.text = "[center]" + str(currentHP) + "[/center]"
	tween.tween_property(armorBar, "value", armor, 0.1)
	
	armorLabel.text = "[center]" + str(armor) + "[/center]"

func reset_armor():
	
	armor = 0
	
func set_health_to_full():
	
	currentHP = maxHP
