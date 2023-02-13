extends Area2D

@export var is_interaction = false
@export var quest_name = ""
@export var target:Node2D
@export var step_index = -1

func set_quest_name(quest:String) -> void:
	quest_name = quest

func set_target(target):
	self.target = target

func interact():
	if target == null:
		return
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body == target:
			QuestManager.progress_quest(quest_name)
			queue_free()
			break


func _on_body_entered(body):
	if is_interaction:
		return
	if QuestManager.has_quest(quest_name) == false:
		return
	if target == null:
		return
	if body == target:
		QuestManager.progress_quest(quest_name)
		queue_free()
