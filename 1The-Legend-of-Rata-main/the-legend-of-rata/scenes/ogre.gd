extends CharacterBody2D

@export var max_health: int = 100
var current_health: int

# Signal to tell the UI health bar to update
signal health_changed(current_health, max_health)

func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

# Called when the Ogre takes damage from the player's attack
func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(current_health, 0)
	emit_signal("health_changed", current_health, max_health)
	
	print("Ogre took damage! Current health: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Ogre defeated!")
	queue_free()

# This function triggers when something enters the Ogre's hitbox area
func _on_ogre_hitbox_body_entered(body: Node2D) -> void:
	# Check if the body that touched the ogre is our player
	if body.has_method("take_damage"):
		body.take_damage()
