extends Area2D

func _on_body_entered(body):
	print("Touched:", body.name)

	if body.is_in_group("Player"):
		print("Calling add_xp()")
		body.add_xp(1)
		queue_free()
