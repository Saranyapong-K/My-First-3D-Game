extends Node2D


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_try_again_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().change_scene_to_file("res://town.tscn")

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
