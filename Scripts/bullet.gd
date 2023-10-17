extends Area2D

@onready var sfx = $SFX
@export var speed: int = 200

const MAX_DIST = 300
var start = Vector2.ZERO
var velocity: Vector2

func manhattan_dist(a, b: Vector2) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func set_velocity(v: Vector2):
	velocity = v
	
func set_angle(a: float):
	velocity = Vector2.UP.rotated(a)

func _ready():
	start = position
	sfx.play()

func _physics_process(delta):
	position += velocity.normalized() * delta * speed
	
	var dist = manhattan_dist(position, start)
	if dist > MAX_DIST:
		queue_free()

func _on_body_entered(body):
	if body != get_parent():
		body.explode()
		queue_free()
