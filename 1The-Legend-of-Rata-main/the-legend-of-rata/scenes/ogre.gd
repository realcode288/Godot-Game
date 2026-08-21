extends CharacterBody2D

@export var max_health: int = 100
var current_health: int
var player = null 

@export var speed: float = 60.0
@export var chase_range: float = 250.0 # Maximum distance the ogre will track you before giving up

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = get_node_or_null("CollisionShape2D")
@onready var detection_area = get_node_or_null("DetectionArea") 
@onready var ogre_hitbox = get_node_or_null("OgreHitbox")     

var default_detection_x: float = 0.0
var default_hitbox_x: float = 0.0

signal health_changed(current_health, max_health)

func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)
	
	if detection_area:
		default_detection_x = detection_area.position.x
	if ogre_hitbox:
		default_hitbox_x = ogre_hitbox.position.x

func _physics_process(delta: float) -> void:
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Fallback safety: Always find the player node in the group if we don't have a direct reference yet
	if not player:
		var potential_player = get_tree().get_first_node_in_group("player")
		if potential_player and global_position.distance_to(potential_player.global_position) <= chase_range:
			player = potential_player

	# Only chase if the player is assigned and within reasonable bounds
	if player and global_position.distance_to(player.global_position) <= (chase_range * 1.5):
		var distance_x = player.global_position.x - global_position.x
		var direction = 0.0
		
		if abs(distance_x) > 2.0:
			direction = sign(distance_x)
		else:
			direction = -1.0 if animated_sprite.flip_h else 1.0
		
		# Set horizontal velocity 
		velocity.x = direction * speed
		
		# --- CORRECT FACING & POSITION FLIPPING ---
		var moving_left = (direction < 0)
		
		# 1. Flip visual sprite
		animated_sprite.flip_h = moving_left
		
		# 2. Shift hitboxes and detection areas to match side
		if detection_area:
			detection_area.position.x = -default_detection_x if moving_left else default_detection_x
			
		if ogre_hitbox:
			ogre_hitbox.position.x = -default_hitbox_x if moving_left else default_hitbox_x
		# ------------------------------------------
		
		if animated_sprite.sprite_frames.has_animation("walk"):
			animated_sprite.play("walk")
	else:
		# If player gets too far away, drop target and idle
		player = null
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

# Detection Area Signals (Used for initial aggro trigger)
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	# We intentionally keep tracking them even if they briefly leave the area box, 
	# as long as they are within the chase_range limit handled in physics_process!
	pass

# Hurtbox / Hitbox Signal (when ogre touches the player)
func _on_ogre_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage()
