extends Node2D

@export var backgroundPolygon : Polygon2D

@export var visualCombatActor : VisualCombatActor

@export var cursorSprite : Sprite2D

func _ready():
	
	visualCombatActor.wibble_the_icon(cursorSprite, cursorSprite.scale, 0.015)
	Globals.currentLevel = self
