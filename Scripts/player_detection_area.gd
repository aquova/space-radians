extends Area2D

var player = null

signal player_seen
signal player_lost

func _on_body_entered(body):
	player = body
	player_seen.emit()

func _on_body_exited(_body):
	player = null
	player_lost.emit()

func get_player():
	return player
