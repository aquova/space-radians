extends Node2D

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var enemy_container = $Enemies
@onready var level_trans = $LevelTitle
@onready var hud = $HUD
@onready var radar = $HUD/Radar
@onready var return_timer = $ReturnTitleTimer
@onready var enemy_ship = preload("res://Scenes/enemy_ship.tscn")
@onready var space_station = preload("res://Scenes/space_station.tscn")

@onready var shield_powerup_scene = preload("res://Scenes/shield_powerup.tscn")
@onready var laser_powerup_scene = preload("res://Scenes/laser_powerup.tscn")
@onready var life_powerup_scene = preload("res://Scenes/life_powerup.tscn")

const SPAWN_DIST = 200
const MAX_DIST = 500
const POWERUP_ODDS = 10
const MAX_ENEMIES = 20

const ENEMY_PTS = 100
const LEVEL_PTS = 200
const POWERUP_PTS = 50

var SHIELD_RANGE = range(1, 51)
var LASER_RANGE = range(51, 95)
var LIFE_RANGE = range(95, 101)

enum State {
	PLAYING,
	PAUSED,
	TRANS,
	GAMEOVER,
}

var lives = 3
var level = 1
var points = 0
var exit_to_menu = false
var state: State
var remaining_enemies: int

func _ready():
	randomize()
	transition_level()
	
func _input(_event):
	match state:
		State.TRANS:
			return
		State.GAMEOVER:
			if exit_to_menu:
				if Input.is_action_just_pressed("ui_shoot") or Input.is_action_just_pressed("ui_engines"):
					get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
		_:
			if Input.is_action_just_pressed("ui_pause"):
				state = State.PLAYING if state == State.PAUSED else State.PAUSED
				set_paused(state == State.PAUSED)
		
func _process(_delta):
	wrap_enemies()
	var pos: Array[Vector2] = []
	for enemy in enemy_container.get_children():
		if not enemy.is_exploding():
			pos.append(enemy.get_position())
	radar.update_ticks(player.get_position(), pos)
	
func start_level():
	state = State.PLAYING
	hud.set_visible(true)
	# Clear out all enemies when switching levels
	# This *should* be unneccesary, but is here as a safety
	for enemy in enemy_container.get_children():
		enemy.queue_free()
	# Odd levels have just enemies
	# Even levels have just space station
	# Except for multiples of 5, which have both
	var is_mult_five = level % 5 == 0
	var is_even = level % 2 == 0
	if is_even or is_mult_five:
		var num_turrets = floori(level / 2.0) * 2
		spawn_station(num_turrets)
	if not is_even or is_mult_five:
		var num_enemies = min(1 + level, MAX_ENEMIES)
		spawn_enemies(num_enemies)
	update_hud()
	
func transition_level():
	state = State.TRANS
	level_trans.start(level)
	hud.set_visible(false)
	
func spawn_enemies(num: int):
	for i in range(num):
		# Spawn new enemy at random position relative to player
		var angle = randf() * TAU
		var spawn_pos = randi_range(SPAWN_DIST, 2 * SPAWN_DIST)
		var pos = Vector2(player.position.x + cos(angle) * spawn_pos, player.position.y + sin(angle) * spawn_pos)
		spawn_ship(pos)
	
func spawn_ship(pos: Vector2):
	var enemy = enemy_ship.instantiate()
	enemy.set_position(pos)
	enemy_container.add_child(enemy)
	enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	remaining_enemies += 1
	
func spawn_station(num_turrets: int):
	var angle = randf() * TAU
	var pos = Vector2(player.position.x + cos(angle) * 2 * SPAWN_DIST, player.position.y + sin(angle) * 2 * SPAWN_DIST)

	var station = space_station.instantiate()
	station.set_num_turrets(num_turrets)
	remaining_enemies += num_turrets
	station.set_position(pos)
	enemy_container.add_child(station)
	station.turret_destroyed.connect(_on_enemy_destroyed)

func drop_powerup(pos: Vector2):
	var odds = randi_range(1, 100)
	if odds < POWERUP_ODDS:
		var pu: Object
		var roll = randi_range(1, 100)
		if SHIELD_RANGE.has(roll):
			pu = shield_powerup_scene.instantiate()
		elif LASER_RANGE.has(roll):
			pu = laser_powerup_scene.instantiate()
		elif LIFE_RANGE.has(roll):
			pu = life_powerup_scene.instantiate()
		else:
			assert(false, "You made a mistake with the powerup ranges")
		pu.set_position(pos)
		call_deferred("add_child", pu)
		
func wrap_enemies():
	# Wrap enemies around our position to stop them from getting too far away
	for enemy in enemy_container.get_children():
		var diff = enemy.get_position() - player.get_position()
		if diff.length() > MAX_DIST:
			enemy.set_position(diff.rotated(PI) + player.get_position())

func set_paused(paused: bool):
	get_tree().paused = paused
	hud.show_paused(paused)

func update_hud():
	hud.display_enemy_count(remaining_enemies)
	hud.display_lives(lives)
	hud.display_points(points)

func _on_level_title_begin_playing():
	start_level()

func _on_player_player_died():
	lives -= 1
	update_hud()
	if lives == 0:
		state = State.GAMEOVER
		Highscore.set_highscore(points)
		return_timer.start()
		hud.gameover()
		player.gameover()

func _on_player_extra_life():
	lives += 1
	update_hud()

func _on_enemy_destroyed(pos: Vector2):
	drop_powerup(pos)
	remaining_enemies -= 1
	camera.start_shaking()
	points += ENEMY_PTS
	if remaining_enemies == 0:
		level += 1
		points += LEVEL_PTS
		transition_level()
	update_hud()

func _on_player_grab_powerup():
	points += POWERUP_PTS
	update_hud()
	
func _on_return_title_timer_timeout():
	exit_to_menu = true
