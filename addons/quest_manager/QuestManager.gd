@tool
extends Node

signal quest_completed()
signal quest_failed()
signal step_complete()
signal step_updated()
signal new_quest_added()
signal quest_reset()

const ACTION_STEP = "action_step"
const INCREMENTAL_STEP = "incremental_step"
const ITEMS_STEP = "items_step"
const TIMER_STEP = "timer_step"
#Helper variable for searching for quest
var active_quest = ""

var current_resource:QuestResource
var player_quests = {}
#---TIMER_STEP VARIABLE-------
var counter = 0.0
#used to update timer steps individually

#loads and add a quest to player quests from quest_resource
func add_quest_from_resource(resource:QuestResource,quest_name:String) -> void:
	current_resource = resource
	add_quest(quest_name)
	step_updated.emit(get_current_step(quest_name))

#loads the Quest resource to view/accept quests
func load_quest_resource(resource:QuestResource) -> void:
	current_resource = resource

#Get a quest that the player has accepted
func get_player_quest(quest_name:String) -> Dictionary:
	var quest_data = {}
	for quest in player_quests:
		if player_quests[quest].quest_name == quest_name:
			quest_data = player_quests[quest]
	return quest_data

#all the current quests the player has
func get_all_player_quests() -> Dictionary:
	return player_quests
	
#returns all player quests names as array
func get_all_player_quests_names() -> Array:
	var quests = []
	for i in player_quests:
		quests.append(player_quests[i].quest_name)
	return quests

#Progresses a quest to its next step
#completes quest if it was at its last step
func progress_quest(quest_name:String, quest_item:String="",amount:int=1,completed:bool=true) -> void:
	active_quest = quest_name
	if has_quest(quest_name) == false:
		return
	if is_quest_complete(quest_name):
		return
	var id = get_player_quest(quest_name).quest_id
	var step = get_current_step(quest_name)
	match step.step_type:
		ACTION_STEP:
			step.complete = true
			step_complete.emit(get_current_step(quest_name))
			player_quests[id].step_index += 1
		INCREMENTAL_STEP:
			if step.item_name != quest_item:
				return
			step.collected += amount
			step_updated.emit(get_current_step(quest_name))
			if step.collected >= step.required:
				step_complete.emit(get_current_step(quest_name))
				player_quests[id].step_index += 1
		ITEMS_STEP:
			for item in step.item_list:
				if item.name == quest_item:
					item.complete = completed
					step_updated.emit(get_current_step(quest_name))
			var missing_items = false
			for item in step.item_list:
				if item.complete == false:
					missing_items = true
			if missing_items == false:
				step_complete.emit(get_current_step(quest_name))
				player_quests[id].step_index += 1
		TIMER_STEP:
			if quest_item != "":
				#prevents progress quest calls that contains item
				return
			step_complete.emit(get_current_step(quest_name))
			player_quests[id].step_index += 1

	var total_steps = player_quests[id].steps.size()
	if player_quests[id].step_index >= total_steps:
		complete_quest(quest_name)
	else:
		step_updated.emit(get_current_step(quest_name))

#Updates Timer_Steps
func _process(delta):
	if Engine.is_editor_hint():
		return
	counter += delta
	for quest in get_quests_in_progress():
		var step = get_current_step(player_quests[quest].quest_name)
		if step.is_empty():
			return
		if step.step_type != TIMER_STEP:
			return
		if counter >= 1.0:
			if step.is_count_down:
				step.time -= 1
				if step.time <= 0:
					if step.fail_on_timeout:
						fail_quest(player_quests[quest].quest_name)
					else:
						progress_quest(player_quests[quest].quest_name)
			else:
				step.time += 1
				if step.time >= step.total_time:
					if step.fail_on_timeout:
						fail_quest(player_quests[quest].quest_name)
					else:
						progress_quest(player_quests[quest].quest_name)
						
			step_updated.emit(step)
	if counter >= 1.0:
		counter = 0
	
#------------------------------
#Set a specific value for Incremental and Item Steps
#For example the player could have some of an item
#already use this to match the players inventory
func set_quest_step_items(quest_name:String,quest_item:String,amount:int=0,collected:bool=false) -> void:
	var step = get_current_step(quest_name)
	match step.step_type:
		INCREMENTAL_STEP:
			if step.item_name == quest_item:
				step.collected = amount
		ITEMS_STEP:
			for item in step.item_list:
				if item.name == quest_item:
					item.complete = collected
					step_updated.emit(get_current_step(quest_name))
	step_updated.emit(step)
#Optionally get quests that were grouped by group name grouped to all by default
func get_quest_list(group:String="") -> Dictionary:
	if group == "":
		return current_resource.quest_data
	var quests = {}
	for quest in current_resource.quest_data:
		if current_resource.quest_data[quest].group == group:
			quests[quest] = current_resource.quest_data[quest]
	assert(current_resource != null, "Quest Resource not Loaded")
	return quests

#Adds quest from the current loaded resource
#to the player_quests list
func add_quest(quest_name:String) -> void:
	var quest = get_quest_from_resource(quest_name)
	player_quests[quest.quest_id] = quest.duplicate(true)
	new_quest_added.emit(quest_name)
	active_quest = quest_name

#Add a quest that was created from script/at runtime
func add_scripted_quest(quest:ScriptQuest):
	player_quests[quest.quest_data.quest_id] = quest.quest_data
	new_quest_added.emit(quest.quest_data.quest_name)
	active_quest = quest.quest_data.quest_name

#Get a quest from the current loaded resource
#Usefull for displaying quest data
func get_quest_from_resource(quest_name:String) -> Dictionary:
	var quest_data = {}
	for quest in current_resource.quest_data:
		if current_resource.quest_data[quest].quest_name == quest_name:
			for entry in current_resource.quest_data[quest]:
				quest_data[entry] = current_resource.quest_data[quest][entry]
			#quest_data = current_resource.quest_data[quest]
			break
	assert(!quest_data.is_empty(),"The Quest: %s was not found in loaded resource" % quest_name)
	return quest_data

#Return true if the player currently has a quest
func has_quest(quest_name:String) -> bool:
	for i in player_quests:
		if player_quests[i].quest_name == quest_name:
			return true
	return false
#Returns all the player quests that are not
#completed or not have been failed
func get_quests_in_progress():
	var active_quests = {}
	for quest in player_quests:
		if player_quests[quest].failed or player_quests[quest].completed:
			continue
		active_quests[quest] = player_quests[quest]
	return active_quests
#return true if quest is complete
func is_quest_complete(quest_name:String) -> bool:
	if has_quest(quest_name)==false:
		return false
	var quest = get_player_quest(quest_name)
	return quest.completed
#returns true if quest was failed
func is_quest_failed(quest_name) -> bool:
	var quest = get_player_quest(quest_name)
	if quest.is_empty():
		return false
	return quest.failed
	
#get the current step in quest
func get_current_step(quest_name:String) -> Dictionary:
	if has_quest(quest_name)==false:
		return {}
	var quest = get_player_quest(quest_name)
	if quest.step_index >= quest.steps.size():
		return {}
	if is_quest_complete(quest_name):
		return {}
	return quest.steps[quest.step_index]

#Remove quest from player quests including steps/items and metadata
func remove_quest(quest_name:String) -> void:
	for i in player_quests:
		if player_quests[i].quest_name == quest_name:
			player_quests.erase(i)
#returns a dictionary of all the rewards of a player quest
func get_quest_rewards(quest_name:String) -> Dictionary:
	var quest_rewards ={}
	for quest in player_quests:
		if player_quests[quest].quest_name == quest_name:
			quest_rewards = player_quests[quest].quest_rewards
			break
	return quest_rewards
	
#Completes a quest if every required step was completed
func complete_quest(quest_name:String) -> void:
	var id = get_player_quest(quest_name).quest_id
	player_quests[id].completed = true
	#emits quest name and rewards dictionary
	quest_completed.emit(quest_name,get_quest_rewards(quest_name))

#get all the meta data stored for this quest
func get_meta_data(quest_name:String) -> Dictionary:
	var meta_data ={}
	for quest in player_quests:
		if player_quests[quest].quest_name == quest_name:
			meta_data = player_quests[quest].meta_data
			break
	return meta_data


#sets or create new quests meta data
func set_meta_data(quest_name:String,meta_data:String, value:Variant) -> void:
	var id = get_player_quest(quest_name).quest_id
	player_quests[id].metadata[meta_data] = value

#Fails a quest
func fail_quest(quest_name:String) -> void:
	var id = get_player_quest(quest_name).quest_id
	player_quests[id].failed = true
	quest_failed.emit(quest_name)
	
#Reset Quest Values
func reset_quest(quest_name:String) -> void:
	var id = get_player_quest(quest_name).quest_id
	player_quests[id].completed = false
	player_quests[id].failed = false
	player_quests[id].step_index = 0
	for step in player_quests[id].steps:
		match step.step_type:
			ACTION_STEP:
				step.complete = false
			INCREMENTAL_STEP:
				step.collected = 0
			ITEMS_STEP:
				for i in step.items_list:
					i.complete = false
			TIMER_STEP:
				if step.is_count_down:
					step.time = step.total_time
				else:
					step.time = 0
	quest_reset.emit(quest_name)
	
#Removes Every Quest from player 
#Usefull for new game files if neccessary
func wipe_quest_data() -> void:
	player_quests = {}

func get_random_id() -> String:
	randomize()
	#seed(Time.get_unix_time_from_system())
	return str(randi() % 1000000).sha1_text().substr(0, 10)
	
