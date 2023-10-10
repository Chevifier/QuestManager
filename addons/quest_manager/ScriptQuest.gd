class_name ScriptQuest
var quest_data = {}
var last_added_id = ""
#Note Script Quest dont currently support branches
func _init(quest_name:String,quest_details :String= "") -> void:
	quest_data["quest_id"] = get_random_id()
	quest_data["quest_name"]= quest_name
	quest_data["quest_details"]= quest_details
	quest_data["first_step"]= ""
	quest_data["quest_steps"] = {}
	quest_data["completed"]= false
	quest_data["failed"]= false
	quest_data["group"]= ""
	quest_data["meta_data"]= {}
	quest_data["quest_rewards"]= {}
	
func set_quest_details(details:String) -> void:
	quest_data["quest_details"] = details

func add_action_step(step_details:String,step_meta_data:Dictionary={}) -> void:
	var step_data = {}
	step_data["id"] = get_random_id()
	step_data["step_type"] = "action_step"
	step_data["details"] = step_details
	step_data["meta_data"] = step_meta_data
	step_data["complete"] = false
	step_data["next_id"] = ""
	add_step(step_data)

func add_incremental_step(step_details:String, item_name:String, required:int,step_meta_data:Dictionary={}) -> void:
	var step_data = {}
	step_data["id"] = get_random_id()
	step_data["next_id"] = ""
	step_data["step_type"] = "incremental_step"
	step_data["details"] = step_details
	step_data["item_name"] = item_name
	step_data["required"] = required
	step_data["collected"] = 0
	step_data["meta_data"] = step_meta_data
	step_data["completed"] = false
	add_step(step_data)

func add_items_step(step_details:String, items:PackedStringArray,step_meta_data:Dictionary={}) -> void:
	var step_data = {}
	step_data["id"] = get_random_id()
	step_data["next_id"] = ""
	step_data["step_type"] = "items_step"
	step_data["details"]= step_details
	var arr = []
	for item in items:
		arr.append({
		"name" : item,
		"complete" : false
		})
	step_data["item_list"]= arr
	step_data["complete"] = false
	step_data["meta_data"]= step_meta_data
	add_step(step_data)

func add_callable_step(function:String,params:Array = []) -> void:
	var step_data = {}
	step_data["id"] = get_random_id()
	step_data["next_id"] = ""
	step_data["step_type"] = "callable_step"
	step_data["details"] = function
	step_data["callable"] = function
	step_data["params"] = params
	step_data["complete"] = false
	add_step(step_data)
#add a timer step
func add_timer_step(step_details:String,time_in_seconds:int,is_count_down:bool = true,fail_on_timeout:bool=true,step_meta_data:Dictionary={}) -> void:
	var step_data = {}
	step_data["id"] = get_random_id()
	step_data["next_id"] = ""
	step_data["step_type"]= "timer_step"
	step_data["details"]= step_details
	step_data["total_time"]=  time_in_seconds
	step_data["time"]= time_in_seconds if is_count_down else 0
	step_data["is_count_down"]= is_count_down
	step_data["fail_on_timeout"]= fail_on_timeout
	step_data["time_minutes"]= round(time_in_seconds/60)
	step_data["time_seconds"]= time_in_seconds%60
	step_data["meta_data"]= step_meta_data
	step_data["complete"] = false
	add_step(step_data)
	

#set quest rewards dictionary
func set_rewards(rewards:Dictionary) -> void:
	quest_data["quest_rewards"] = rewards

#set quest meta_data dictionary
func set_quest_meta_data(meta_data:Dictionary) -> void:
	quest_data["meta_data"] = meta_data

#add quest to group
func add_quest_to_group(group:String) -> void:
	quest_data["group"] = group

#add step also setting first step
func add_step(step_data:Dictionary) -> void:
	quest_data["quest_steps"][step_data["id"]] = step_data
	if quest_data["first_step"] == "":
		quest_data["first_step"] = step_data["id"]
		quest_data["next_id"] = step_data["id"]
		last_added_id = step_data["id"]
	else:
		quest_data["quest_steps"][last_added_id]["next_id"] = step_data["id"];
		last_added_id = step_data["id"]

#must call after adding all steps to quest
func finalize_quest() -> void:
	assert(quest_data["quest_steps"].is_empty()==false,"No Quest steps Added")
	var end_data = {}
	end_data["id"] = get_random_id()
	end_data["step_type"] = "end"
	end_data["details"] = "Complete"
	quest_data["quest_steps"][end_data["id"]] = end_data
	add_step(end_data)
	
func get_random_id() -> String:
	randomize()
	#seed(Time.get_unix_time_from_system())
	return str(randi() % 1000000).sha1_text().substr(0, 10)
	
