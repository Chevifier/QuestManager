class_name QMQuest extends Node
var quest = {}
func set_quest(quest_data:Dictionary) -> void:
	quest = quest_data
	set_current_step(quest.next_id)

func set_current_step(step_id:String):
	var step_data = quest.quest_steps[quest.next_id]
	var step_instance = null
	match step_data.step_type:
		QuestManager.ACTION_STEP:
			step_instance = QMQuestStep.new()
		QuestManager.INCREMENTAL_STEP:
			step_instance = QMIncrementalStep.new()
		QuestManager.ITEMS_STEP:
			step_instance = QMItemsStep.new()
		QuestManager.TIMER_STEP:
			step_instance = QMTimerStep.new()
		QuestManager.BRANCH_STEP:
			step_instance = QMBranchStep.new()
		QuestManager.CALLABLE_STEP:
			step_instance = QMCallableStep.new()
		QuestManager.END:
			step_instance = QMEndStep.new()
	add_child(step_instance)
	step_instance.step_complete.connect(_on_step_complete)
	step_instance.set_step_data(step_data)
#called by child node with next_id


func _on_item_collected(item_name):
	pass
	
func _on_incremental_item_collected(item_name,quantity:int):
	pass

func _on_branch_activated(is_branching):
	pass

func _on_step_complete(step):
	set_next_step(step.next_id)

func set_next_step(next_id):
	quest.next_id = next_id
	set_current_step(quest.next_id)

func complete_quest():
	quest.completed = true
	QuestManager.quest_completed.emit(quest)
	queue_free()
	
	
	
