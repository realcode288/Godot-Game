extends CharacterBody2D

# Hardcoded direct file path completely bypassing export variables
var fire_ball: PackedScene = preload("res://fire_ball.tscn")

@onready var shoot_timer = $ShootTimer

var boss_health = 5
var fire_count = 0


func _ready() -> void:
	# Automatically wire the timer's timeout signal to our attack code
	shoot_timer.wait_time = 2.0
	shoot_timer.timeout.connect(shoot_fireball)
	shoot_timer.start()


func shoot_fireball() -> void:
	# Checks if the boss is dead or if the scene file is missing
	if boss_health <= 0 or fire_ball == null:
		return

	# Increment the fireball count
	fire_count += 1

	# Determine if this shot is the 3rd deflectable one
	var can_be_deflected = false

	if fire_count >= 3:
		can_be_deflected = true
		fire_count = 0  # Reset the counter back to 0

	# Instantiate and launch the fireball into the game level scene
	var ball = fire_ball.instantiate()
	get_parent().add_child(ball)

	# Spawn it slightly to the left side of the boss position
	ball.global_position = global_position + Vector2(-30, 0)

	# Launch left (-1, 0) and pass the deflection rule
	ball.setup(Vector2.LEFT, can_be_deflected)


func take_boss_damage() -> void:
	boss_health -= 1

	print("Boss Hit! Health remaining: ", boss_health)

	if boss_health <= 0:
		boss_defeat()


func boss_defeat() -> void:
	shoot_timer.stop()

	print("Boss Defeated!")

	queue_free()  # Destroys the boss node


	
