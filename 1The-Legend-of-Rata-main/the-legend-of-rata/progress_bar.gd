extends ProgressBar

func _ready() -> void:
	visible = true
	add_to_group("boss_health_bar")
	print("PROGRESS BAR IS ALIVE AND IN THE SCENE!")
	
	# Force it to a visible size and position on screen
	size = Vector2(400, 40)
	position = Vector2(100, 100)
	
	max_value = 500
	value = 500

func show_boss_bar(current_hp: int, max_hp: int) -> void:
	max_value = max_hp
	value = current_hp

func update_health(current_hp: int, max_hp: int) -> void:
	max_value = max_hp
	value = current_hp
	if current_hp <= 0:
		visible = false
