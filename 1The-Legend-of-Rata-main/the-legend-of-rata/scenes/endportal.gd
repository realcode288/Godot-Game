extends Area2D

@export_file("*.tscn") var end_credits_scene: String = "res://scenes/end_credits.tscn"

func _ready() -> void:
	# --- HIDE AND DISABLE PORTAL AT SPAWN ---
	hide()
	monitoring = false
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

# Call this function from your ogre script to make the portal appear after defeat!
func activate_portal() -> void:
	show()
	monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player entered the portal! Loading end credits...")
		# Use call_deferred to safely change the scene outside of the physics callback
		call_deferred("_change_scene")

func _change_scene() -> void:
	get_tree().change_scene_to_file(end_credits_scene)
