extends Area2D

@export var item_name = "Apple"
@export var quest_name = "Quest"



func _on_body_entered(body):
	if body.name == "Player":
		#QuestManager.progress_quest("quest_name")
		body.apples += 1
		get_parent().notify_collected()
		queue_free()
