extends Area2D

func _physics_process(delta):
	var vel = Vector2(0,-600) * delta
	position += vel
	
	if position.y < -50:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		area.queue_free()
		$QMStepTracker.update_step()
	queue_free()

