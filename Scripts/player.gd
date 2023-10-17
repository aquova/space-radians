extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var engine_particles = $EngineParticles
@onready var explosion_particles = $ExplosionParticles
@onready var muzzle_container = $Muzzles
var bullet_scene = preload("res://Scenes/bullet.tscn")
var shield_material = preload("res://Materials/shield.tres")

enum State {
	FLYING,
	EXPLODING,
	GAMEOVER,
}

const SPEED = 100
const A_SPEED = 1.5 * PI
const MAX_I_TIME = 0.6
const MAX_LASERS = 3

signal extra_life
signal grab_powerup
signal player_died

var actual_velocity: Vector2
var engine_velocity: Vector2
var state: State
var has_shield: bool
var num_lasers: int
var i_time: float

func _ready():
	respawn()
	
func respawn():
	state = State.FLYING
	actual_velocity = Vector2.UP
	engine_velocity = Vector2.UP
	has_shield = false
	num_lasers = 1
	sprite.set_visible(true)
	sprite.set_material(null)
	collision_shape.set_deferred("disabled", true)
	i_time = 0
	sprite.set_rotation(0)
	engine_particles.set_rotation(0)
	for muzzle in muzzle_container.get_children():
		muzzle.reset()

func _physics_process(delta):
	if i_time < MAX_I_TIME:
		i_time += delta
		if i_time >= MAX_I_TIME:
			collision_shape.set_deferred("disabled", false)
			
	if state == State.EXPLODING or state == State.GAMEOVER:
		return
		
	if Input.is_action_just_pressed("ui_shoot"):
		shoot()
	
	if Input.is_action_pressed("ui_right"):
		turn(A_SPEED * delta)
	elif Input.is_action_pressed("ui_left"):
		turn(-A_SPEED * delta)
		
	var engines_on = not Input.is_action_pressed("ui_engines")
	engine_particles.set_emitting(engines_on)
	if engines_on:
		actual_velocity = engine_velocity
	
	var collision = move_and_collide(actual_velocity * SPEED * delta)
	if collision:
		explode()
		collision.get_collider().explode()

func turn(da: float):
	engine_velocity = engine_velocity.rotated(da)
	sprite.rotate(da)
	engine_particles.rotate(da)
	for muzzle in muzzle_container.get_children():
		muzzle.set_position(muzzle.get_position().rotated(da))
	
func explode():
	if has_shield:
		has_shield = false
		sprite.set_material(null)
		return
	state = State.EXPLODING
	player_died.emit()
	collision_shape.set_deferred("disabled", true)
	sprite.set_visible(false)
	engine_particles.set_emitting(false)
	explosion_particles.start()
	
func gameover():
	state = State.GAMEOVER

func create_bullet(pos: Vector2):
	var b = bullet_scene.instantiate()
	b.set_position(pos)
	b.set_rotation(sprite.get_rotation())
	b.set_velocity(engine_velocity)
	add_child(b)

func shoot():
	if num_lasers > 1:
		create_bullet($Muzzles/DualMuzzleA.position)
		create_bullet($Muzzles/DualMuzzleB.position)
	if num_lasers != 2:
		create_bullet($Muzzles/SingleMuzzle.position)
	
func powerup(type: Powerup.PowerupType):
	match type:
		Powerup.PowerupType.SHIELD:
			has_shield = true
			sprite.set_material(shield_material)
		
		Powerup.PowerupType.LASERS:
			num_lasers = min(num_lasers + 1, MAX_LASERS)
			
		Powerup.PowerupType.LIFE:
			extra_life.emit()
			
		Powerup.PowerupType.INVALID:
			assert(false, "Invalid powerup picked up")
	grab_powerup.emit()

func _on_explosion_particles_effect_finished():
	if state != State.GAMEOVER:
		respawn()
