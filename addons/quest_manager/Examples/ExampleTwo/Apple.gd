extends Area2D
@export var step_index = 1
@export var item_name = "Apple"
@export var quest_name = "Meal For The Family"


func _on_body_entered(body):
	if body.name == "Player":
		if QuestManager.has_quest(quest_name) and QuestManager.is_quest_complete(quest_name)==false:
			if QuestManager.get_current_step(quest_name).index == step_index:
				QuestManager.progress_quest(QuestManager.active_quest,item_name)
		body.apples += 1
		get_parent().notify_collected()
		queue_free()
