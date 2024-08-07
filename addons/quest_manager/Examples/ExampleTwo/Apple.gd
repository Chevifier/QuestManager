extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		$QMStepTracker.update_step()
		body.apples += 1
		get_parent().notify_collected()
		queue_free()
