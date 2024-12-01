extends Area3D

@export var respawn_time = 5.0  # Time in seconds for the feather to respawn

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("collect_glide_powerup"):  # Check if the entering body has the "collect_glide_powerup" function
		body.collect_glide_powerup()  # Grant glide ability to the player
		hide()  # Hide the feather instead of freeing it
		set_collision_layer(0)  # Disable collision
		set_collision_mask(0)
		await get_tree().create_timer(respawn_time).timeout
		respawn()  # Call respawn function after the delay

func respawn() -> void:
	show()  # Show the feather again
	set_collision_layer(1)  # Re-enable collision
	set_collision_mask(1)
