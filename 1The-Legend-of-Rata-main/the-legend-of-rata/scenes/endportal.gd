extends Area2D

@export_file("*.tscn") var end_credits_scene: String = "res://scenes/end_credits.tscn"

func _ready() -> void:
	# Hides and disables the portal at the start
	hide()
	monitoring = false
	
	if not body_entered.is_connected(_on_body_entered): # For when the player touches the portal
		body_entered.connect(_on_body_entered)

# Makes the portal appear when the boss is deafeated
func activate_portal() -> void:
	show()
	monitoring = true

func _on_body_entered(body: Node2D) -> void: #Checks if player is in the portal
	if body.is_in_group("player"):
		
		# Stops the speedrun timer
		GlobalTimer.stop_timer() 
		
		# safely changes the scene
		call_deferred("_change_scene")

func _change_scene() -> void: #Actually changes the scene
	get_tree().change_scene_to_file(end_credits_scene)
