extends Area2D

@onready var spawn_point: Marker2D = $SpawnPoint

var is_activated: bool = false

func _on_body_entered(body: Node2D) -> void:
	# Stop executing if this checkpoint was already claimed
	if is_activated:
		return
		
	print("Checkpoint touched by: ", body.name)
	
	if "Player" in body.name or body is CharacterBody2D:
		GameManager.last_checkpoint_position = spawn_point.global_position
		is_activated = true
		print("Checkpoint successfully saved!")
		
		# Optional: Play an animation or change the visual sprite here
