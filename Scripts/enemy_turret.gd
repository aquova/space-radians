extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var player_detection = $PlayerDetectionArea
@onready var explosion = $ExplosionParticles
@onready var bullets = $Bullets
@onready var bullet_scene = preload("res://Scenes/enemy_bullet.tscn")

const A_SPEED = 0.5 * PI
const FIRE_THRESHOLD = 0.1 * PI

enum State {
	SEARCHING,
	FIRING,
	EXPLODING,
}

signal enemy_destroyed(position: Vector2)

var state: State
var direction: Vector2
var rot_right: bool

func _ready():
	randomize()
	state = State.SEARCHING
	direction = Vector2.UP
	rot_right = randf() > 0.5
	
func _physics_process(delta):
	match state:
		State.SEARCHING:
			var sgn = 1 if rot_right else -1
			turn(sgn * A_SPEED * delta)
		State.FIRING:
			chase_player(delta)
		State.EXPLODING:
			return
	
func turn(theta: float):
	direction = direction.rotated(theta)
	sprite.rotate(theta)
	
func chase_player(delta: float):
	# Rotate enemy to face player
	var player = player_detection.get_player()
	var player_dir = player.get_global_position() - global_position
	var theta = direction.angle_to(player_dir)
	turn(sign(theta) * A_SPEED * delta)
	if bullets.get_child_count() == 0 and abs(theta) < FIRE_THRESHOLD:
		shoot()
		
func shoot():
	if state != State.FIRING:
		return
	var b = bullet_scene.instantiate()
	b.set_velocity(direction)
	bullets.add_child(b)

func explode():
	if state != State.EXPLODING:
		state = State.EXPLODING
		sprite.set_visible(false)
		collision.set_deferred("disabled", true)
		enemy_destroyed.emit(global_position)
		for bullet in bullets.get_children():
			bullet.queue_free()
		explosion.start()

func is_exploding() -> bool:
	return state == State.EXPLODING

func _on_player_detection_area_player_seen():
	state = State.FIRING

func _on_player_detection_area_player_lost():
	state = State.SEARCHING

func _on_explosion_particles_effect_finished():
	queue_free()
