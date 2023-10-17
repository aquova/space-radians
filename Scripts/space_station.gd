extends Node2D

@onready var sprite = $Sprite2D
@onready var marker_container = $TurretMarkers
@onready var turret_container = $Turrets
@onready var explosion_container = $Explosions
@onready var turret_scene = preload("res://Scenes/enemy_turret.tscn")

enum State {
	NORMAL,
	EXPLODING,
}

signal turret_destroyed(pos: Vector2)

var state: State
var num_turrets: int

func _ready():
	state = State.NORMAL
	var markers = marker_container.get_children()
	num_turrets = min(num_turrets, markers.size())
	for i in range(0, num_turrets):
		var marker = markers[i]
		var turret = turret_scene.instantiate()
		turret.enemy_destroyed.connect(_on_enemy_destroyed)
		turret.set_position(marker.get_position())
		turret_container.add_child(turret)

func set_num_turrets(num: int):
	num_turrets = num

func is_exploding() -> bool:
	return state == State.EXPLODING

func explode():
	state = State.EXPLODING
	sprite.set_visible(false)
	for explosion in explosion_container.get_children():
		explosion.start()

func _on_enemy_destroyed(pos: Vector2):
	turret_destroyed.emit(pos)
	num_turrets -= 1
	if num_turrets == 0:
		explode()

func _on_explosion_particles_effect_finished():
	# This is only one of the explosion effects
	# But they should all finish around the same time
	queue_free()
