extends Control

func _on_button_pressed() -> void: # when pressing this button puts you on the main menu
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
