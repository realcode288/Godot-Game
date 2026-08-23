extends CharacterBody2D

@export var max_health: int = 500
var current_health: int
var player = null 

@export var speed: float = 60.0
@export var chase_range: float = 250.0 
@export var sprite_faces_left: bool = true 

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = get_node_or_null("CollisionShape2D")
@onready var detection_area = get_node_or_null("DetectionArea") 
@onready var ogre_hitbox = get_node_or_null("OgreHitbox")     

var default_detection_x: float = 0.0
var default_hitbox_x: float = 0.0

var last_direction: float = 1.0

signal health_changed(current_health, max_health)

func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)
	
	if detection_area:
		default_detection_x = abs(detection_area.position.x)
	if ogre_hitbox:
		default_hitbox_x = abs(ogre_hitbox.position.x)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not player:
		var potential_player = get_tree().get_first_node_in_group("player")
		if potential_player and global_position.distance_to(potential_player.global_position) <= chase_range:
			player = potential_player

	if player and global_position.distance_to(player.global_position) <= (chase_range * 1.5):
		var distance_x = player.global_position.x - global_position.x
		var direction = 0.0
		
		if abs(distance_x) > 5.0:
			direction = sign(distance_x)
			last_direction = direction 
		else:
			direction = last_direction
		
		velocity.x = direction * speed
		
		var moving_left = (direction < 0)
		
		if sprite_faces_left:
			animated_sprite.flip_h = not moving_left 
		else:
			animated_sprite.flip_h = moving_left    
			
		if detection_area:
			detection_area.position.x = -default_detection_x if moving_left else default_detection_x
			
		if ogre_hitbox:
			ogre_hitbox.position.x = -default_hitbox_x if moving_left else default_hitbox_x
		
		if animated_sprite.sprite_frames.has_animation("walk"):
			animated_sprite.play("walk")
	else:
		player = null
		velocity.x = move_toward(velocity.x, 0, speed)
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(global_position)

func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(current_health, 0)
	emit_signal("health_changed", current_health, max_health)
	
	print("Ogre took damage! Current health: ", current_health)
	
	var health_bar = get_tree().get_first_node_in_group("boss_health_bar")
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_health, max_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Ogre defeated!")
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		print("Player entered Ogre detection range!")
		
		var health_bar = get_tree().get_first_node_in_group("boss_health_bar")
		if health_bar:
			print("Health bar found!")
			if health_bar.has_method("show_boss_bar"):
				health_bar.show_boss_bar(current_health, max_health)
		else:
			print("WARNING: Health bar not found in group!")

func _on_detection_area_body_exited(body: Node2D) -> void:
	pass

func _on_ogre_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(global_position)

func _on_ogre_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Attack Hitbox" or (area.get_parent() and area.get_parent().is_in_group("player")):
		take_damage(25)
