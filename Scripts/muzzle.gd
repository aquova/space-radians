extends Marker2D

var start_pos: Vector2

func _ready():
	start_pos = position

func reset():
	set_position(start_pos)
