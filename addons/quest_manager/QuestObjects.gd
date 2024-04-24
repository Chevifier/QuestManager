#(WIP=Not implemented)
#Quest objects are used to auto update each quest step
#they are created for active quests only
#you connent signals to the functions to process the
#current step related to that function
class_name QuestObject extends RefCounted
var quest_id = ""
var current_step = ""
var next_id = ""
#stored objects by their id
var step_objects = {}

func _init(_quest_id) -> void:
	quest_id = _quest_id
	for step in QuestManager.player_quests[quest_id].quest_steps:
		match step.step_type:
			"action_step":
				var action_step = ActionStep.new(step.id)
				step_objects[step.id] = action_step
				pass
			"incremental_step":
				var inc_step = IncrementalStep.new(step.id)
				step_objects[step.id] = inc_step
			"items_step":
				var item_step = ItemsStep.new(step.id)
				step_objects[step.id] = item_step
			"timer_step":
				var timer_step = ItemsStep.new(step.id)
				step_objects[step.id] = timer_step
			"branch_step":
				var branch_step = ItemsStep.new(step.id)
				step_objects[step.id] = branch_step
			"callable_step":
				var callabe_step = ItemsStep.new(step.id)
				step_objects[step.id] = callabe_step
			"end":
				var end_step = ItemsStep.new(step.id)
				step_objects[step.id] =end_step

func _action_event(action=true):
	if action:
		next_id = step_objects[current_step].set_complete(quest_id)

func _incremental_event(id:String,amount :int= 1):
	pass
	
func _item_event(item_name:String):
	pass
	
func _function_call_event(v):
	pass
	
func process_timer_steps(delta):
	if QuestManager.player_quests[quest_id].steps[current_step].step_type == "timer_step":
		pass


class ActionStep:
	var id =""
	func _init(_id) -> void:
		id = _id
	func set_complete(quest_id):
		QuestManager.player_quests[quest_id].steps[id].complete
		QuestManager.step_complete.emit(QuestManager.player_quests[quest_id].steps[id])
		return QuestManager.player_quests[quest_id].steps[id].next_id
	
class IncrementalStep:
	var id =""
	func _init(_id) -> void:
		id = _id
	pass

class ItemsStep:
	var id =""
	func _init(_id) -> void:
		id = _id
	pass
	
class BranchStep:
	var id =""
	func _init(_id) -> void:
		id = _id
	pass

class TimerStep:
	var id =""
	func _init(_id) -> void:
		id = _id
	pass
