extends Camera2D

const POWER = 3
const TIME = 0.4

var shaking: bool
var current_pos: Vector2
var elapsed_t: float

func _ready():
	randomize()
	current_pos = offset
	shaking = false

func _process(delta):
	if shaking:
		shake(delta)
		
func start_shaking():
	if not shaking:
		elapsed_t = 0
		shaking = true

func shake(delta: float):
	if elapsed_t < TIME:
		offset = Vector2(randf(), randf()) * POWER
		elapsed_t += delta
	else:
		shaking = false
		offset = current_pos
