extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Prints a message to check if things are colliding correctly
	print("Something entered the killzone: ", body.name)
	
	# If the object that fell in has a "die" function, trigger it!
	if body.has_method("die"):
		body.die()
