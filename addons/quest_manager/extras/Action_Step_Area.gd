extends Area2D
#Helper Class for positional Actions
#i.e Go to location (WIP)
#Requires a Collision shape to be added

func _on_body_entered(body):
	if body.name == "Player":
		print(QuestManager.active_quest)
		$QMStepTracker.update_step()
		queue_free()
