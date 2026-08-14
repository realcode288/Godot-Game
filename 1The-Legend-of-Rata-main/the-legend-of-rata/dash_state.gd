extends BossState

@export var dash_speed: float = 400.0
var player: CharacterBody2D
var dash_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	# Locate the player node in your level scene dynamically
	player = get_tree().get_first_node_in_group("Player")
	if player:
		dash_direction = (player.global_position - boss.global_position).normalized()
	
	# Transition back to idle automatically after 1.5 seconds
	get_tree().create_timer(1.5).timeout.connect(func():
		change_to_idle()
	)

func physics_update(_delta: float) -> void:
	if boss:
		boss.velocity = dash_direction * dash_speed
		boss.move_and_slide()

func change_to_idle() -> void:
	if get_parent().current_state == self:
		get_parent().transition_to("IdleState")
