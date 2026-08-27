extends Control

# Button 1: Goes to Normal Mode
func _on_button_pressed() -> void:
	GlobalTimer.speedrun_mode = false 
	GlobalTimer.running = false
	get_tree().change_scene_to_file("res://game.tscn")

# Button 3: Goes to the Lore Tab
func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lore.tscn")

# Button 2: Goes to the Controls Tab
func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/controls.tscn")

# Button 4: Goes to Speedrun Mode
func _on_button_4_pressed() -> void:
	GlobalTimer.speedrun_mode = true 
	GlobalTimer.start_timer()        
	get_tree().change_scene_to_file("res://game.tscn")
