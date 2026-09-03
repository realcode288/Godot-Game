extends Area2D

@onready var spawn_point: Marker2D = $SpawnPoint

var is_activated: bool = false

func _on_body_entered(body: Node2D) -> void:
	# Stops executing if the checkpoint was already claimed
	if is_activated:
		return
	
	if "Player" in body.name or body is CharacterBody2D: # saves the last checkpoint position the player touched
		GameManager.last_checkpoint_position = spawn_point.global_position
		is_activated = true
