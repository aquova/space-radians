extends GPUParticles2D

@onready var finished_timer = $FinishedTimer
@onready var points_label = $PointsLabel
@onready var sfx = $SFX

signal effect_finished

func start():
	set_emitting(true)
	finished_timer.start()
	points_label.start()
	sfx.play()

func _on_finished_timer_timeout():
	effect_finished.emit()
