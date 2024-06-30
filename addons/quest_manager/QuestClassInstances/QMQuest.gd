class_name QMQuest extends Node

var quest = {}
func _init(_quest_name,step_id) -> void:
	quest = QuestManager.get_player_quest(_quest_name)
	set_current_step(step_id)

func set_current_step(step_id:String):
	var next_id = quest.next_id
	var step_data = QuestManager.get_current_step(quest.quest_name)
	var step_instance = null
	match step_data.step_type:
		QuestManager.ACTION_STEP:
			step_instance = QMQuestStep.new(step_data)
		QuestManager.INCREMENTAL_STEP:
			step_instance = QMIncrementalStep.new(step_data)
		QuestManager.ITEMS_STEP:
			step_instance = QMItemsStep.new(step_data)
		QuestManager.TIMER_STEP:
			pass
		QuestManager.BRANCH_STEP:
			pass
		QuestManager.CALLABLE_STEP:
			pass
		QuestManager.END:
			pass
	add_child(step_instance)
	
#called by child node with next_id
func set_next_step(next_id):
	quest.next_id = next_id
	set_current_step(quest.next_id)
