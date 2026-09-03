extends ProgressBar

func _ready() -> void:
	visible = true
	add_to_group("boss_health_bar")
	
	# Forces the bar to a visible size and position
	size = Vector2(400, 40)
	position = Vector2(100, 100)
	
	max_value = 500 #health values
	value = 500

func show_boss_bar(current_hp: int, max_hp: int) -> void:# shows the bar if the boss is still alive
	max_value = max_hp
	value = current_hp

func update_health(current_hp: int, max_hp: int) -> void: #shows the hp and how much it is at
	max_value = max_hp
	value = current_hp
	if current_hp <= 0:
		visible = false
