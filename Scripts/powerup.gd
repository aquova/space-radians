extends Area2D

class_name Powerup

@onready var collision_shape = $CollisionShape2D
@onready var points_label = $PointsLabel
@onready var sfx = $SFX
@onready var sprite = $Sprite2D
@onready var vanish_timer = $VanishTimer

enum PowerupType {
	INVALID,
	SHIELD,
	LASERS,
	LIFE,
}

@export var type: PowerupType

func _ready():
	vanish_timer.start()

func _on_body_entered(body):
	body.powerup(type)
	collision_shape.set_deferred("disabled", true)
	sprite.set_visible(false)
	points_label.start()
	sfx.play()

func _on_vanish_timer_timeout():
	queue_free()

func _on_sfx_finished():
	queue_free()
