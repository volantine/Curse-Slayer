extends Node2D


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/World.tscn")

func _on_controls_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Controls.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
