extends CharacterBody2D

const SPEED = 150.0  # Sets the players speed and jump height
const JUMP_VELOCITY = -250.0 

# on ready variables go here
@onready var animated_sprite = $AnimatedSprite2D 
@onready var hitbox_shape = $"Attack Hitbox/CollisionShape2D"
@onready var camera = $Camera2D 

# Regular variables go here
var is_attacking = false 
var is_hurt = false
var is_invincible = false

# Thees shake the camera when you take damage
var shake_intensity: float = 0.0
var shake_decay: float = 15.0

# invicinbility duration after you get hit
var invincibility_duration: float = 1.0 
var invincibility_time_left: float = 0.0

# Functions go here
func _ready() -> void:
	add_to_group("player") #sets the hitbox
	if hitbox_shape:
		hitbox_shape.disabled = true

func _process(delta: float) -> void: # code for the camera shaking
	if camera and shake_intensity > 0:
		shake_intensity = move_toward(shake_intensity, 0, shake_decay * delta)
		camera.offset.x = randf_range(-shake_intensity, shake_intensity)
		camera.offset.y = randf_range(-shake_intensity, shake_intensity)
	elif camera:
		camera.offset = Vector2.ZERO

	if is_invincible: # code for the invicibility mechanism
		invincibility_time_left -= delta
		animated_sprite.visible = fmod(Time.get_ticks_msec() / 50.0, 2.0) < 1.0
		
		if invincibility_time_left <= 0:
			is_invincible = false
			animated_sprite.visible = true
	else:
		animated_sprite.visible = true

func _physics_process(delta: float) -> void: # makes you not able to jump in the air
	if not is_on_floor():
		velocity += get_gravity() * delta 

	if is_hurt: # gets knockback when you take damage and makes it so that you can't move
		move_and_slide()
		return

	if Input.is_action_just_pressed("attack") and not is_attacking: # attacking mechanism
		start_attack()

	if is_attacking:  #makes you not able to move when you are attacking
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		update_animations()
		return

	if Input.is_action_just_pressed("move_up") and is_on_floor(): # uses the jump height and checks if you are on the floor
		velocity.y = JUMP_VELOCITY 

	var direction := Input.get_axis("move_left", "move_right") # makes the player to move left and right
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = (direction < 0)
		$"Attack Hitbox".scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animations()

func update_animations() -> void: # plays the attack animation
	if is_hurt:
		return 
	if is_attacking:
		if animated_sprite.animation != "attack":
			animated_sprite.play("attack")
		return

	if not is_on_floor(): # plays the animations
		animated_sprite.play("jump")
	else:
		if velocity.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

func start_attack() -> void: 
	is_attacking = true
	
	await get_tree().create_timer(0.1).timeout # player cant get hit when you are attacking
	if hitbox_shape and is_attacking:
		hitbox_shape.disabled = false
	
	await get_tree().create_timer(0.15).timeout 
	if hitbox_shape:
		hitbox_shape.disabled = true
		
	await get_tree().create_timer(0.1).timeout
	if is_attacking:
		is_attacking = false

func take_damage(attacker_position: Vector2 = Vector2.ZERO, forced_direction: float = 0.0) -> void: #knocks the player back
	if is_hurt or is_invincible: 
		return
		
	is_hurt = true
	is_invincible = true
	is_attacking = false 
	invincibility_time_left = invincibility_duration  #plays the invinbility frames
	
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
		
	animated_sprite.play("hurt") # plays the hurt animation
	shake_intensity = 8.0 
	
	# Fixed the directional knockback
	if forced_direction != 0.0:
		velocity.x = forced_direction * 120.0
	elif attacker_position != Vector2.ZERO:
		var knockback_dir = sign(global_position.x - attacker_position.x)
		if knockback_dir == 0:
			knockback_dir = 1 if not animated_sprite.flip_h else -1
		velocity.x = knockback_dir * 120.0
	else:
		velocity.x = 100 if animated_sprite.flip_h else -100
		
	velocity.y = -120

func _on_animated_sprite_2d_animation_finished() -> void: # finishes the attack and hurt animations
	if animated_sprite.animation == "attack":
		is_attacking = false
	elif animated_sprite.animation == "hurt":
		is_hurt = false

func respawn() -> void: # killzone respawns you at the last checkpoint you touched
	if GameManager.last_checkpoint_position != Vector2.ZERO:
		global_position = GameManager.last_checkpoint_position
		velocity = Vector2.ZERO 
	else:
		get_tree().call_deferred("reload_current_scene")
		
func _unhandled_input(event: InputEvent) -> void: # respawn function
	if event.is_action_pressed("ui_cancel"): 
		respawn()

func _input(event: InputEvent) -> void: # takes damage from 
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		take_damage()
		
func die() -> void:
	print("Player died!")
	
	if GameManager.last_checkpoint_position != Vector2.ZERO: # checkpoint
		global_position = GameManager.last_checkpoint_position
		velocity = Vector2.ZERO 
	else:
		get_tree().call_deferred("reload_current_scene")
