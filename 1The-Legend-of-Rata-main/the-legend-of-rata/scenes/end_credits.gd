extends Control

func _on_button_pressed() -> void:
	print("Retuirning to Main Menu")
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
