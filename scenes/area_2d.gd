extends Area2D





func _on_body_exited(body):
	if(body is RigidBody2D):
		print("kys")
		get_parent().get_parent().queue_free()
