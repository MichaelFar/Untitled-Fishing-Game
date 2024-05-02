extends Sprite3D


func _ready():
	create_rotation_tween()

func create_rotation_tween():
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation:y", 2 * PI, 1.5)
	
	tween.finished.connect(create_rotation_tween)
