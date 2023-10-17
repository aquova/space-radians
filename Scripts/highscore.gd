extends Node

const SAVEPATH = "user://space_radians.sav"

var highscore: int

func _ready():
	highscore = load_highscore()

func get_highscore() -> int:
	return highscore
	
func set_highscore(pts: int):
	if pts > highscore:
		highscore = pts
		write_highscore(highscore)

func write_highscore(hs: int):
	var save_file = FileAccess.open(SAVEPATH, FileAccess.WRITE)
	save_file.store_var({"highscore": hs})
	save_file.close()
	
func load_highscore() -> int:
	if not FileAccess.file_exists(SAVEPATH):
		return 0
	var save_file = FileAccess.open(SAVEPATH, FileAccess.READ)
	var data = save_file.get_var()
	save_file.close()
	return data["highscore"]
