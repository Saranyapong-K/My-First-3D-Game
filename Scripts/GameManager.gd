extends Node3D

# ---------- VARIABLES ---------- #

var score = 0
const COINS_TO_WIN = 10
var current_level := 1
# ---------- FUNCTIONS ---------- #

func _process(_delta):
	pass

func add_score():
	score += 1
	if score >= COINS_TO_WIN:
		if current_level == 1:
			call_deferred("_load_next_scene")
		elif current_level == 2:
			call_deferred("_load_win_scene")
func _load_next_scene():
	score = 0
	get_tree().change_scene_to_file("res://town_lvl_2.tscn")
	
func game_over():
	call_deferred("_do_game_over")

func _do_game_over():
	score = 0
	get_tree().change_scene_to_file("res://GameOver.tscn")
	
func _load_win_scene():
	score = 0
	get_tree().change_scene_to_file("res://win.tscn")
