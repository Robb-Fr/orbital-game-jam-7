class_name arena extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if ("Player" in body.name):
		var sprite = body.get_node("Hint")
		if sprite:
			sprite.set_visible(true)

func _on_body_exited(body: Node2D) -> void:
	if ("Player" in body.name):
		var sprite = body.get_node("Hint")
		if sprite:
			sprite.set_visible(false)
