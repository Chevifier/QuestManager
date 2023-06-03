class_name ScriptQuest
var quest_data = {}

var steps = []
#Step Types
enum {
ACTION_STEP,
INCREMENTAL_STEP,
ITEM_STEP,
TIMER_STEP
}
func _init(quest_name:String):
	quest_data["quest_id"] = QuestManager.get_random_id()
	quest_data["quest_name"] = quest_name

func add_step(quest_step:QuestStep):
	steps.append(quest_step.data)

func set_quest_details(details:String):
	quest_data["quest_details"] = details

#set quest rewards dictionary
func set_rewards(rewards:Dictionary):
	quest_data["quest_rewards"] = rewards

#set quest meta_data dictionary
func set_quest_meta_data(meta_data:Dictionary):
	quest_data["meta_data"] = meta_data

#add quest to group
func add_quest_to_group(group:String):
	quest_data["group"] = group

#must call after adding all steps to quest
func finalize_quest():
	quest_data["steps"] = steps
	quest_data["completed"] = false
	quest_data["failed"] = false
	quest_data["step_index"]= 0
	
class QuestStep:

	var data = {
		"step_type" : "action_step",
		"details": "",
		"meta_data" : {},
	}
	
	func _init(step_type):
		match step_type:
			ACTION_STEP:
				data["step_type"] = "action_step"
			INCREMENTAL_STEP:
				data["step_type"] = "incremental_step"
			ITEM_STEP:
				data["step_type"] = "items_step"
			TIMER_STEP:
				data["step_type"] = "timer_step"
	
	func set_step_details(details:String):
		data["details"] = details
		if data["step_type"] == "action_step":
			data["completed"] = false
	
	func set_incremental_data(item_name:String, required:int):
		assert(data["step_type"] == "incremental_step", "Step is not Incremental Step")
		data["item_name"] = item_name
		data["required"] = required
		data["collected"] = 0
		
	func set_item_step_items(items:Array):
		assert(data["step_type"] == "items_step", "Step is not Item Step")
		data["item_list"] = items
		
	func set_timer_data(time_in_seconds:int, is_count_down:bool = true,fail_on_timeout:bool = true):
		assert(data["step_type"] == "timer_step", "Step is not Timer Step")
		data["total_time"] = time_in_seconds
		data["time"] = time_in_seconds if is_count_down else 0
		data["is_count_down"] = is_count_down
		data["fail_on_timeout"] = fail_on_timeout
		var minutes = 0
		var seconds = 0
		for i in time_in_seconds:
			seconds+=1
			if seconds == 60:
				minutes+=1
				seconds=0
		data["time_minutes"] = minutes
		data["time_seconds"] = seconds
		
	#set meta data for this step
	func set_step_meta_data(meta_data:Dictionary):
		data["meta_data"] = meta_data


