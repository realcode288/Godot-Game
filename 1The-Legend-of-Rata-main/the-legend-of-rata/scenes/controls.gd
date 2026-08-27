extends Control

func _on_button_pressed() -> void: # Switches scenes to the main menu
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
