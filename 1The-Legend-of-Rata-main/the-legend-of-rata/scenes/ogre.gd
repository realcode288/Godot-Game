extends CharacterBody2D

@export var max_health: int = 100
var current_health: int
var player = null 
var is_dead: bool = false 

@export var speed: float = 60.0
@export var chase_range: float = 250.0 
@export var sprite_faces_left: bool = true 

# Safety net: Triggers defeat if the ogre falls past this Y-coordinate (adjust in Inspector if needed)
@export var death_y_boundary: float = 800.0 

# Preload the portal scene to spawn upon defeat
const PORTAL_SCENE = preload("res://scenes/endportal.tscn")

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = get_node_or_null("DetectionArea") 
@onready var ogre_hitbox = get_node_or_null("OgreHitbox")       

var default_detection_x: float = 0.0
var default_hitbox_x: float = 0.0
var last_direction: float = 1.0
var last_safe_position: Vector2 = Vector2.ZERO # Tracks where it was safe before falling

signal health_changed(current_health, max_health)

func _ready() -> void: #Sets the current health to the maximum health value when the node enters the scene tree and emits the health changed signal.
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)
	
	if detection_area: #Stores the detection area's starting offset to help with flipping direction later.
		default_detection_x = abs(detection_area.position.x)
	if ogre_hitbox: #Stores the hitbox's starting offset to help with flipping direction later.
		default_hitbox_x = abs(ogre_hitbox.position.x)

func _physics_process(delta: float) -> void:
	# Stops executing physics process logic if the ogre is already dead.
	if is_dead:
		return

	# Keep track of where the ogre safely is while on the platform
	if is_on_floor():
		last_safe_position = global_position

	# If it falls past the platform kill it
	if global_position.y > death_y_boundary:
		is_dead = true
		if last_safe_position == Vector2.ZERO:
			last_safe_position = global_position
			last_safe_position.y = death_y_boundary - 50 
			
		take_damage(current_health) # Deals enough damage to instantly kill the ogre if it falls out of bounds.
		return

	if not is_on_floor(): #Applies gravity when the ogre is in the air.
		velocity += get_gravity() * delta

	if not player: # Searches for a player node in the scene if one isn't currently assigned and checks if they are within chase range.
		var potential_player = get_tree().get_first_node_in_group("player")
		if potential_player and global_position.distance_to(potential_player.global_position) <= chase_range:
			player = potential_player

#Handles chasing the player when they are within range
	if player and global_position.distance_to(player.global_position) <= (chase_range * 1.5):
		var distance_x = player.global_position.x - global_position.x
		var direction = 0.0
		
		if abs(distance_x) > 5.0: #Decides which way to move toward the player, keeping the last direction if the distance is too small.
			direction = sign(distance_x)
			last_direction = direction 
		else:
			direction = last_direction
		
		# Moves left or right.
		velocity.x = direction * speed
		
		var moving_left = (direction < 0)
		
		# Flips the sprite to face movement direction.
		if sprite_faces_left:
			animated_sprite.flip_h = not moving_left 
		else:
			animated_sprite.flip_h = moving_left    
			
		# Moves the detection area to match facing direction.
		if detection_area:
			detection_area.position.x = -abs(default_detection_x) if moving_left else abs(default_detection_x)
			
		# Moves the hitbox to match facing direction.
		if ogre_hitbox:
			ogre_hitbox.position.x = -abs(default_hitbox_x) if moving_left else abs(default_hitbox_x)
		
		# Plays the walking animation.
		if animated_sprite.sprite_frames.has_animation("move"):
			animated_sprite.play("move")
	else:
		# Stops moving and plays idle animation when out of range.
		player = null
		velocity.x = move_toward(velocity.x, 0, speed)
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")

	# Applies movement and collisions.
	move_and_slide()

	# Hurts the player on contact.
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(global_position, last_direction)

func take_damage(amount: int) -> void:
	# Ignores damage if already dead.
	if is_dead and amount < current_health:
		return

	# Takes damage and updates health.
	current_health -= amount
	current_health = max(current_health, 0)
	# Broadcasts health change.
	emit_signal("health_changed", current_health, max_health)
	
	print("Ogre took damage! Current health: ", current_health)
	
	# Updates the health bar UI.
	var health_bar = get_tree().get_first_node_in_group("boss_health_bar")
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_health, max_health)
	
	# Triggers death if health hits zero.
	if current_health <= 0:
		is_dead = true
		call_deferred("die")

func die() -> void:
	print("Ogre defeated!")
	
	# Switches music back to normal.
	MusicManager.play_normal_music()
	
	# Spawns the end portal.
	if PORTAL_SCENE:
		var portal_instance = PORTAL_SCENE.instantiate()
		
		# Places portal safely.
		if last_safe_position != Vector2.ZERO and global_position.y > death_y_boundary:
			portal_instance.global_position = last_safe_position
		else:
			portal_instance.global_position = global_position
			
		# Adds portal to the scene.
		get_tree().current_scene.add_child(portal_instance)
		
		# Activates the portal.
		if portal_instance.has_method("activate_portal"):
			portal_instance.activate_portal()
			
		print("Portal appeared on the platform!")

	# Deletes the ogre node.
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	# Ignores if dead.
	if is_dead:
		return
	# Starts the boss fight when player enters.
	if body.is_in_group("player"):
		player = body
		print("Player entered Ogre detection range!")
		
		# Switches music to boss track.
		MusicManager.play_boss_music()
		
		# Shows the boss health bar.
		var health_bar = get_tree().get_first_node_in_group("boss_health_bar")
		if health_bar and health_bar.has_method("show_boss_bar"):
			health_bar.show_boss_bar(current_health, max_health)

func _on_ogre_hitbox_body_entered(body: Node2D) -> void:
	# Ignores if dead.
	if is_dead:
		return
	# Hurts player on hitbox contact.
	if body.has_method("take_damage"):
		body.take_damage(global_position, last_direction)

func _on_ogre_hitbox_area_entered(area: Area2D) -> void:
	# Ignores if dead.
	if is_dead:
		return
	# Takes damage from player attacks.
	if area.name == "Attack Hitbox" or (area.get_parent() and area.get_parent().is_in_group("player")):
		take_damage(5)
