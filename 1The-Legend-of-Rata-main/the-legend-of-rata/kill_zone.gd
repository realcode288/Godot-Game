extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# If the player touches the kill zone alert
	if body.has_method("die"):
		body.die()
