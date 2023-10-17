extends CanvasLayer

@onready var lives_container = $LifeIcons
@onready var enemy_count_label = $EnemyCountLabel
@onready var pause_label = $PauseLabel
@onready var point_label = $PointLabel
@onready var gameover_label = $GameoverLabel
@onready var radar = $Radar
@onready var life_icon = preload("res://Scenes/life_icon.tscn")
@onready var hs_material = preload("res://Materials/highscore.tres")

func display_lives(cnt: int):
	if cnt == 0:
		return
	var display_num = cnt - 1
	var num_icons = lives_container.get_child_count()
	if num_icons == display_num:
		return
	elif num_icons > display_num:
		for i in range(num_icons - display_num):
			lives_container.get_child(-1).queue_free()
	else:
		for i in range(display_num - num_icons):
			var icon = life_icon.instantiate()
			lives_container.add_child(icon)

func display_enemy_count(cnt: int):
	enemy_count_label.set_text("Enemies: " + str(cnt))
	
func display_points(pts: int):
	point_label.set_text(str(pts) + " pts")
	if pts > Highscore.get_highscore():
		point_label.set_material(hs_material)

func show_paused(paused: bool):
	pause_label.set_visible(paused)

func gameover():
	enemy_count_label.set_visible(false)
	radar.set_visible(false)
	point_label.set_visible(false)
	gameover_label.set_visible(true)
