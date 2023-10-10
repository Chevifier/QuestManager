extends Area2D
@export var item_name = "Apple"


func _on_body_entered(body):
	if body.name == "Player":
		QuestManager.progress_quest(QuestManager.active_quest,item_name)
		body.apples += 1
		get_parent().notify_collected()
		queue_free()
