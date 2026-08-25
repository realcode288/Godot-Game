extends Control

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lore.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/controls.tscn")

func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
