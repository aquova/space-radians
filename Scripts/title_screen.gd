extends Node2D

@onready var highscore_label = $HUD/HighscoreLabel

func _ready():
	var hs = Highscore.get_highscore()
	highscore_label.set_text("Highscore - " + str(hs))

func _input(_event):
	if Input.is_action_just_pressed("ui_shoot") or Input.is_action_just_pressed("ui_engines"):
		get_tree().change_scene_to_file("res://Scenes/game.tscn")
