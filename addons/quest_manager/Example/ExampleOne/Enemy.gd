extends Area2D
const SPEED = 300


func _physics_process(delta):
	var velocity = Vector2.DOWN * SPEED * delta
	position += velocity
	
	if position.y > 1000:
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
		queue_free()
