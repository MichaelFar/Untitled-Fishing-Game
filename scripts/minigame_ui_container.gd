extends Control

@export var textLabel : RichTextLabel

@export var timer : Timer

var phrase : String

var splitPhrase := []

var currentIndex = 0

signal intro_phrase_done

func _ready():
	calculate_position()

func calculate_position():

	var viewport_rect = get_viewport_rect()
	
	position = viewport_rect.get_center() - (textLabel.size * textLabel.scale / 2.0)
	
func convert_phrase_to_list():
	
	timer.start()
	splitPhrase = phrase.split(" ")


func _on_timer_timeout():
	
	if(currentIndex != splitPhrase.size()):
		var centered_phrase = "[center]" + splitPhrase[currentIndex] + "[/center]"
		textLabel.text = centered_phrase
		currentIndex += 1
	else:
		timer.stop()
		intro_phrase_done.emit()
		textLabel.queue_free()
