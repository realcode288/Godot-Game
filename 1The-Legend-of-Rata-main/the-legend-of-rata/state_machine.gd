extends Node

@export var initial_state: BossState
var current_state: BossState
var states: Dictionary = {}

func _ready() -> void:
	# Give the parent boss node time to initialize
	await owner.ready 
	
	for child in get_children():
		if child is BossState:
			states[child.name.to_lower()] = child
			child.boss = owner as CharacterBody2D
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func transition_to(new_state_name: String) -> void:
	var target_state = states.get(new_state_name.to_lower())
	if not target_state:
		return
		
	if current_state:
		current_state.exit()
		
	current_state = target_state
	current_state.enter()
