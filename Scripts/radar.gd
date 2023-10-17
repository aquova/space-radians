extends Control

@onready var background = $Background
@onready var tick_container = $TickContainer
@onready var tick_scene = preload("res://Scenes/radar_tick.tscn")

const RADAR_MAX = 300

func update_ticks(player_pos: Vector2, enemy_pos: Array[Vector2]):
	var num_ticks = tick_container.get_child_count()
	# Ensure we have the same number of radar ticks as enemy positions
	if num_ticks < enemy_pos.size():
		for i in range(enemy_pos.size() - num_ticks):
			var t = tick_scene.instantiate()
			tick_container.add_child(t)
	elif enemy_pos.size() < num_ticks:
		for i in range(num_ticks - enemy_pos.size()):
			tick_container.get_child(-1).queue_free()
			
	# Slightly smaller than 50% so objects don't go onto border
	var radar_size = background.get_size() * 0.45
	var radar_r = radar_size.x # Assumes circular radar
	for idx in range(enemy_pos.size()):
		var t = enemy_pos[idx]
		var rel_pos = t - player_pos
		var adjusted_pos = rel_pos / RADAR_MAX * radar_size
		if adjusted_pos.length() > radar_r:
			adjusted_pos = adjusted_pos.normalized() * radar_size
		var tick = tick_container.get_child(idx)
		tick.set_position(adjusted_pos + radar_size)
