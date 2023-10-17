extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var explosion = $ExplosionParticles
@onready var engine_particles = $EngineParticles
@onready var player_detection = $PlayerDetectionArea
@onready var collision_shape = $CollisionShape2D
@onready var rotate_timer = $RotateTimer

const SPEED = 75
const A_SPEED = 0.5 * PI

enum State {
	SEARCHING,
	CHASING,
	EXPLODING,
}

signal enemy_destroyed(position: Vector2)

var state = State.SEARCHING
var target_point: Vector2
var direction: Vector2

func _ready():
	randomize()
	direction = Vector2.UP
	target_point = Vector2.UP
	rotate_timer.start()

func _physics_process(delta):
	match state:
		State.CHASING:
			chase_player(delta)
		State.SEARCHING:
			search(delta)
		State.EXPLODING:
			return
			
	# We'll let the player check collision status, to avoid race conditions
	move_and_collide(direction * SPEED * delta)
	
func chase_player(delta: float):
	# Rotate enemy to face player
	var player = player_detection.get_player()
	var player_dir = player.get_position() - position
	var theta = direction.angle_to(player_dir)
	turn(sign(theta) * A_SPEED * delta)
	
func search(delta: float):
	var theta = direction.angle_to(target_point)
	turn(sign(theta) * A_SPEED * delta)
	
func turn(da: float):
	direction = direction.rotated(da)
	sprite.rotate(da)
	engine_particles.rotate(da)
	
func is_exploding() -> bool:
	return state == State.EXPLODING

func explode():
	if state != State.EXPLODING:
		# Play animation, then destroy ourselves
		state = State.EXPLODING
		sprite.set_visible(false)
		engine_particles.set_emitting(false)
		collision_shape.set_deferred("disabled", true)
		enemy_destroyed.emit(global_position)
		explosion.start()

func _on_rotate_timer_timeout():
	if state == State.SEARCHING and abs(direction.angle_to(target_point)) < PI / 10:
		target_point = Vector2.UP.rotated(randf_range(PI / 4, 7 * PI / 4))

func _on_explosion_particles_effect_finished():
	queue_free()

func _on_player_detection_area_player_lost():
	state = State.SEARCHING
	rotate_timer.set_autostart(true)

func _on_player_detection_area_player_seen():
	state = State.CHASING
	rotate_timer.stop()
