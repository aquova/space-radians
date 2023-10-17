extends Label

@export var points: int = 0

func start():
	if points != 0:
		self.set_visible(true)
		self.set_text(str(points))
		var position_tween = get_tree().create_tween()
		position_tween.tween_property(self, "position:y", -50, 1)
		
		var opacity_tween = get_tree().create_tween()
		opacity_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
		opacity_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
