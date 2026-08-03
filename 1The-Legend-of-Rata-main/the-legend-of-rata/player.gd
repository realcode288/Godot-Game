extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

# References to your nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox_shape = $"Attack Hitbox/CollisionShape2D"

# State variables
var is_attacking = false

func _ready():
	# Make sure the attack hitbox is turned off when the game starts
	if hitbox_shape:
		hitbox_shape.disabled = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 1. HANDLE ATTACK INPUT
	if Input.is_action_just_pressed("attack") and not is_attacking:		start_attack()

	# If we are attacking, stop movement processing and let the attack finish
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	# 2. HANDLE JUMP
	if Input.is_action_just_pressed("move_up") and is_on_floor():		velocity.y = JUMP_VELOCITY

	# 3. HANDLE MOVEMENT
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		# Flip the sprite and the hitbox to face the direction you move
		animated_sprite.flip_h = (direction < 0)
		$"Attack Hitbox".scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# 4. HANDLE MOVEMENT ANIMATIONS (Only plays when moving)
	if is_on_floor():
		if direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

# 5. CONTROL THE ATTACK TIMING
func start_attack():
	is_attacking = true
	animated_sprite.play("attack") # Make sure your attack animation is named "attack"
	
	# Wait a split second for the swing animation frame to hit
	await get_tree().create_timer(0.15).timeout
	if hitbox_shape:
		hitbox_shape.disabled = false
	
	# Keep hitbox active briefly, then turn it off and allow moving again
	await get_tree().create_timer(0.15).timeout
	if hitbox_shape:
		hitbox_shape.disabled = true
	is_attacking = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
		if hitbox_shape:	
			hitbox_shape.disabled = true
