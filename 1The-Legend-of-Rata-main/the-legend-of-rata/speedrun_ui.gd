extends CanvasLayer

@onready var timer_label: Label = $TimerLabel

func _ready() -> void:
	# Hides the timer completely if the player chooses Normal Mode
	if not GlobalTimer.speedrun_mode:
		visible = false
	else:
		visible = true

func _process(_delta: float) -> void: #this displays the timer on the screen
	if GlobalTimer.speedrun_mode:
		timer_label.text = format_time(GlobalTimer.time)

func format_time(seconds: float) -> String: # this is just the timer system
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	var msec = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [mins, secs, msec]
