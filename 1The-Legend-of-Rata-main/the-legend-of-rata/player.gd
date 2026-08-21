extends CharacterBody2D

const SPEED = 150.0 
const JUMP_VELOCITY = -250.0 

# --- ALL @ONREADY VARIABLES GO HERE ---
@onready var animated_sprite = $AnimatedSprite2D 
@onready var hitbox_shape = $"Attack Hitbox/CollisionShape2D"
@onready var camera = $Camera2D 

# --- REGULAR VARIABLES GO NEXT ---
var is_attacking = false 
var is_hurt = false
var is_invincible = false

# Camera shake variables
var shake_intensity: float = 0.0
var shake_decay: float = 15.0

# Built-in invincibility tracker variables (Replaces the need for a Timer Node!)
var invincibility_duration: float = 1.0 # Total duration of safety in seconds
var invincibility_time_left: float = 0.0

# --- FUNCTIONS GO BELOW THIS LINE ---

func _ready() -> void:
	if hitbox_shape:
		hitbox_shape.disabled = true
	
	# Removed the manual .connect() line here to prevent the duplicate connection error!

func _process(delta: float) -> void:
	# 1. CAMERA SHAKE PROCESSING
	if camera and shake_intensity > 0:
		shake_intensity = move_toward(shake_intensity, 0, shake_decay * delta)
		camera.offset.x = randf_range(-shake_intensity, shake_intensity)
		camera.offset.y = randf_range(-shake_intensity, shake_intensity)
	elif camera:
		camera.offset = Vector2.ZERO

	# 2. CODE-BASED INVINCIBILITY TIMER PROCESSING
	if is_invincible:
		# Tick the time left downwards by the delta time frame
		invincibility_time_left -= delta
		
		# Rapidly flicker visibility using internal system clock ticks
		animated_sprite.visible = fmod(Time.get_ticks_msec() / 50.0, 2.0) < 1.0
		
		# Once the countdown hits 0, clear invincibility safely!
		if invincibility_time_left <= 0:
			is_invincible = false
			animated_sprite.visible = true
	else:
		animated_sprite.visible = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta 

	if is_hurt:
		move_and_slide()
		return

	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	if is_attacking: 
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		update_animations()
		return

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY 

	var direction := Input.get_axis("move_left", "move_right") 
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = (direction < 0)
		$"Attack Hitbox".scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animations()

func update_animations() -> void:
	if is_hurt:
		return 
	if is_attacking:
		if animated_sprite.animation != "attack":
			animated_sprite.play("attack")
		return

	if not is_on_floor():
		animated_sprite.play("jump")
	else:
		if velocity.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

func start_attack() -> void: 
	is_attacking = true
	
	# Wait and enable the damage hitbox
	await get_tree().create_timer(0.1).timeout 
	if hitbox_shape and is_attacking:
		hitbox_shape.disabled = false
	
	# Wait and disable the damage hitbox
	await get_tree().create_timer(0.15).timeout 
	if hitbox_shape:
		hitbox_shape.disabled = true
		
	# FAIL-SAFE: Automatically clear attack state if animation signal fails
	await get_tree().create_timer(0.1).timeout
	if is_attacking:
		is_attacking = false

func take_damage() -> void:
	# Ignore the hit if already hurt or already processing invincibility frames
	if is_hurt or is_invincible: 
		return
		
	is_hurt = true
	is_invincible = true
	is_attacking = false 
	invincibility_time_left = invincibility_duration # Set countdown timeline to 1.0 second
	
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
		
	animated_sprite.play("hurt")
	shake_intensity = 8.0 
	
	velocity.x = 100 if animated_sprite.flip_h else -100
	velocity.y = -100

func _on_animated_sprite_2d_animation_finished() -> void: 
	if animated_sprite.animation == "attack":
		is_attacking = false
	elif animated_sprite.animation == "hurt":
		is_hurt = false

func respawn() -> void:
	if GameManager.last_checkpoint_position != Vector2.ZERO:
		global_position = GameManager.last_checkpoint_position
		velocity = Vector2.ZERO 
	else:
		# Use call_deferred here as well just in case respawn is called from physics context
		get_tree().call_deferred("reload_current_scene")
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): 
		respawn()

# Fast input test trigger
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		take_damage()
		
func die() -> void:
	print("Player died!")
	
	# Check if the player has touched a checkpoint yet
	if GameManager.last_checkpoint_position != Vector2.ZERO:
		# Teleport player to the checkpoint marker location
		global_position = GameManager.last_checkpoint_position
		# Stop all movement momentum so you don't instantly fly off ledge
		velocity = Vector2.ZERO 
	else:
		# FIXED: Safely reload scene using call_deferred to avoid physics collision errors
		get_tree().call_deferred("reload_current_scene")
