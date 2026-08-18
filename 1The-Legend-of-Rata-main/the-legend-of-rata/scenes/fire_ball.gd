extends Area2D

const SPEED = 200.0

var direction = Vector2.LEFT  # Boss shoots left by default
var is_deflected = false
var is_deflectable = false  # True only if it's the 3rd fireball


func _ready() -> void:
	# Connect the area overlap signal to check if the player's attack hitbox hits it
	area_entered.connect(_on_area_entered)

	# Connect the body overlap signal to check if it hits the player or boss
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	# Move the fireball continuously
	position += direction * SPEED * delta


# This initializes the fireball's properties when the boss spawns it
func setup(spawn_direction: Vector2, deflectable: bool) -> void:
	direction = spawn_direction
	is_deflectable = deflectable

	# Visual shift: Tints the 3rd fireball blue so the player knows it can be deflected!
	if is_deflectable:
		modulate = Color(0.3, 0.6, 1.0)
	else:
		modulate = Color(1.0, 1.0, 1.0)  # Normal color


func _on_area_entered(area: Area2D) -> void:
	# Checks if the player's "Attack Hitbox" node collides with this fireball
	if area.name == "Attack Hitbox" and is_deflectable and not is_deflected:
		is_deflected = true
		direction = -direction  # Reverse direction back toward the boss

		modulate = Color(0.2, 1.0, 0.2)  # Turns green to show successful reflection


func _on_body_entered(body: Node2D) -> void:
	if not is_deflected:
		# Hits the player if timing is missed or if it's a regular fireball
		if body.name == "player" and body.has_method("take_damage"):
			body.take_damage()

		queue_free()  # Destroy fireball upon impact

	else:
		# Hits the boss after a successful player deflection
		if body.has_method("take_boss_damage"):
			body.take_boss_damage()

		queue_free()  # Destroy fireball upon impact

	# Destroy fireball if it strikes environment terrain boundaries
	if body is TileMapLayer or body.name == "StaticBody2D":
		queue_free()
