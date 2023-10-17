extends CanvasLayer

@onready var title = $TitleLabel
@onready var timer = $PauseTimer
@onready var screen_h = get_viewport().get_content_scale_size().y

signal begin_playing

func start(level: int):
	var title_h = title.get_rect().size.y
	title.position.y = -title_h
	title.set_text("Level " + str(level))
	var tween = get_tree().create_tween()
	tween.tween_property(title, "position:y", screen_h / 4, 0.5)
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(start_pause)
	
func start_pause():
	timer.start()

func _on_pause_timer_timeout():
	var tween = get_tree().create_tween()
	# Go just off screen before ending, it feels nicer
	tween.tween_property(title, "position:y", screen_h + 10, 1)
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(finish)
	
func finish():
	begin_playing.emit()
