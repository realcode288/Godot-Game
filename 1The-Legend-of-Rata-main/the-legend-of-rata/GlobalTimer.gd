extends Node

var speedrun_mode: bool = false # the variables
var time: float = 0.0
var running: bool = false
var best_time: float = 999999.0

func _ready() -> void: #loads the time
	load_best_time()

func _process(delta: float) -> void: #shows the timer
	if running and speedrun_mode:
		time += delta

func start_timer() -> void: #Starts the timer
	time = 0.0
	running = true

func stop_timer() -> void:
	running = false
	if speedrun_mode:
		save_best_time()

# Saves your Personal Best 
func save_best_time() -> void:
	if time < best_time:
		best_time = time
		var config = ConfigFile.new()
		config.set_value("Records", "best_time", best_time)
		config.save("user://speedrun_save.cfg")

# Loads your Personal Best on game startup
func load_best_time() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://speedrun_save.cfg")
	if err == OK:
		best_time = config.get_value("Records", "best_time", 999999.0)
