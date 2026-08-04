extends CharacterBody2D #Just refrencing the player's node

const SPEED = 150.0 # This sets the speed
const JUMP_VELOCITY = -250.0 # This sets the Jump Height


@onready var animated_sprite = $AnimatedSprite2D # References to our nodes
@onready var hitbox_shape = $"Attack Hitbox/CollisionShape2D"

var is_attacking = false # State variables

func _ready():
	# This makes the hitbox off at the start of the game
	if hitbox_shape:
		hitbox_shape.disabled = true

func _physics_process(delta: float) -> void: # Adds the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta # This makes the player not able to jump in mid air

	# 1. HANDLE ATTACK INPUT
	if Input.is_action_just_pressed("attack") and not is_attacking:		start_attack() # The attack mechanism (if the button is pressed the player will attack)


	if is_attacking: 	# If we are attacking, stop movement processing and let the attack finish
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	
	if Input.is_action_just_pressed("move_up") and is_on_floor():		velocity.y = JUMP_VELOCITY # This makes the jump work when we press the chosen key


	var direction := Input.get_axis("move_left", "move_right") # this makes the player move left and right when we press the chosen keys
	if direction:
		velocity.x = direction * SPEED
		# Flip the sprite and the hitbox to face the direction you move (Just visually pleasing)
		animated_sprite.flip_h = (direction < 0)
		$"Attack Hitbox".scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	
	if is_on_floor(): # This handles the movement animations
		if direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")


func start_attack(): # If this is true you can attack
	is_attacking = true
	animated_sprite.play("attack") 
	
	
	await get_tree().create_timer(0.15).timeout # makes the game wait a split second before attacking
	if hitbox_shape:
		hitbox_shape.disabled = false
	
	
	await get_tree().create_timer(0.15).timeout # This lets the attack hitbox go on and off for a split second
	if hitbox_shape:
		hitbox_shape.disabled = true
	is_attacking = false


func _on_animated_sprite_2d_animation_finished() -> void: # This is the finishing animation for the attack
	if animated_sprite.animation == "attack":
		is_attacking = false
		if hitbox_shape:	
			hitbox_shape.disabled = true

func respawn() -> void:
	if GameManager.last_checkpoint_position != Vector2.ZERO:
		global_position = GameManager.last_checkpoint_position
		velocity = Vector2.ZERO # Stops carried-over physics momentum
	else:
		get_tree().reload_current_scene()
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Default Escape/Back key
		respawn()
