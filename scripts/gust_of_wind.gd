extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("apply_gust_force"):
		body.apply_gust_force(true)

func _on_body_exited(body: Node3D) -> void:
	if body.has_method("apply_gust_force"):
		body.apply_gust_force(false)
