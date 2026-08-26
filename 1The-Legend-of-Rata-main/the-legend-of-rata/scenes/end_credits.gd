extends Control

# This links your script to the new label we are about to check
@onready var final_time_label: Label = $FinalTimeLabel

func _ready() -> void:
	# Only show the final score if they actually played on Speedrun Mode
	if GlobalTimer.speedrun_mode:
		final_time_label.visible = true
		final_time_label.text = "Final Time: " + format_time(GlobalTimer.time)
	else:
		final_time_label.visible = false # Keep it hidden during a Normal playthrough

# Formats the final seconds into a clean time string (00:00.00)
func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	var msec = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [mins, secs, msec]

# Your original Main Menu button function
func _on_button_pressed() -> void:
	print("Returning to Main Menu")
	
	# Reset the speedrun values so the next run starts fresh
	GlobalTimer.speedrun_mode = false
	GlobalTimer.running = false
	
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
