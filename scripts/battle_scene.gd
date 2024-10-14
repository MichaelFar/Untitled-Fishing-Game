extends Node2D

@export var visualCombatActor : VisualCombatActor

@export var cursorSprite : Sprite2D

@export var battleVisualContainer : VisualCombatActor

func _ready():
	
	visualCombatActor.wibble_the_icon(cursorSprite, cursorSprite.scale, 0.015)
	
	Globals.currentLevel = self
	
	CombatGlobal.battleVisualContainer = battleVisualContainer
	
	CombatGlobal.connect_hit_and_block_signals()
