extends Area2D

@onready var spawn_point = $SpawnPoint

func _on_body_entered(body: Node2D) -> void:
	# Prints a message to your console window when anything touches it
	print("Checkpoint touched by: ", body.name)
	
	# Detects the player by checking the node name or its script type
	if "Player" in body.name or body is CharacterBody2D:
		GameManager.last_checkpoint_position = spawn_point.global_position
		print("Checkpoint successfully saved!")
