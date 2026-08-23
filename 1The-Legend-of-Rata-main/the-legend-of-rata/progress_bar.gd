extends ProgressBar

func _ready() -> void:
	visible = false
	add_to_group("boss_health_bar")

func show_boss_bar(current_hp: int, max_hp: int) -> void:
	visible = true
	max_value = max_hp
	value = current_hp

func update_health(current_hp: int, max_hp: int) -> void:
	value = current_hp
	if current_hp <= 0:
		visible = false
