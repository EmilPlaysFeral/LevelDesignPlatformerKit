extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("collect_glide_powerup"): # Check if the entering body has the "collect_glide_powerup" function
		body.collect_glide_powerup()  # Call the player's method to grant glide ability
		queue_free()  # Remove the powerup after collection# Replace with function body.
