extends CharacterBody2D

@export var max_health: int = 100
var current_health: int
var player = null 

@export var speed: float = 60.0
@onready var animated_sprite = $AnimatedSprite2D

signal health_changed(current_health, max_health)

func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Only chase if the player is within the DetectionArea
	if player:
		var direction = sign(player.global_position.x - global_position.x)
		
		if is_on_floor():
			velocity.x = direction * speed
			animated_sprite.flip_h = (direction < 0)
		
		if animated_sprite.sprite_frames.has_animation("walk"):
			animated_sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")

	move_and_slide()

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

# Detection Area Signals
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null

# Hurtbox / Hitbox Signal (when ogre touches the player)
func _on_ogre_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage()
