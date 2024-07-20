extends Control

@export var textLabel : RichTextLabel

@export var timer : Timer

var introPhrase : String

var scoreText : String

var splitPhrase := []

var scoreLabelSize := Vector2.ZERO

var currentIndex = 0

var readyToReturnToFishing := false

signal intro_phrase_done

func _ready():
	
	scoreLabelSize = textLabel.size
	
	calculate_position()

func _physics_process(delta):
	if(readyToReturnToFishing):
		if(Input.is_action_just_released("cast")):
			LevelTransition.transition_to_fishing_game(FishingPondsStorage.currentPond)

func calculate_position():

	var viewport_rect = get_viewport_rect()
	
	position = viewport_rect.get_center() - (textLabel.size * textLabel.scale / 2.0)
	
func convert_phrase_to_list():
	
	timer.start()
	splitPhrase = introPhrase.split(" ")

func _on_timer_timeout():
	
	if(currentIndex != splitPhrase.size()):
		var centered_phrase = "[center]" + splitPhrase[currentIndex] + "[/center]"
		textLabel.text = centered_phrase
		currentIndex += 1
	else:
		timer.stop()
		intro_phrase_done.emit()
		textLabel.size = Vector2(1, 0)

func display_end(end_screen_string : String):
	
	readyToReturnToFishing = true
	textLabel.text = end_screen_string
	textLabel.size = scoreLabelSize
