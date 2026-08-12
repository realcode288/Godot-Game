extends Area2D


func _on_body_entered(body):
	print("You died!")
	Engine.time_scale = 0.5
