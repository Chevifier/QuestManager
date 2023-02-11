extends Node
signal new_quest_added()
signal quest_progressed()
signal quest_item_collected()
signal quest_failed()
signal quest_completed()
signal quest_reset()

var current_resource:QuestResource
var player_quests = {}


func _ready():
	pass
#all the current quests the player has
func get_all_player_quests():
	return player_quests

#loads the Quest resource to view/accept quests
func load_quest_resource(res:QuestResource):
	current_resource = res

#Optionally get quests that were grouped by group name grouped to all by default
func get_quest_list(group=""):
	if group == "":
		return current_resource.quest_data
	var quests = {}
	for quest in current_resource.quest_data:
		if current_resource.quest_data[quest].group == group:
			quests[quest] = current_resource.quest_data[quest]
	assert(current_resource != null, "Quest Resource not Loaded")
	return quests

#Get a quest that the player has accepted
func get_player_quest(quest_name=""):
	var quest_data = {}
	for quest in player_quests:
		if player_quests[quest].quest_name == quest_name:
			quest_data = player_quests[quest]
	assert(quest_data.is_empty()==false,"The Quest: %s was not found in loaded resource" % quest_name)
	return quest_data
	
#Get the current step progress in one of the players quests
func get_quest_current_step(quest_name= ""):
	var quest = get_player_quest(quest_name).step_index
	var step_index = quest.step_index
	assert(step_index > quest.steps.size()-1,"Index out of bounds")
	var step_id = quest.steps[step_index]
	return player_quests.steps[step_id]

#Adds quest from the current loaded resource
#to the player_quests list
func add_quest(quest_name, quest_id=""):
	var quest = get_quest_from_resource(quest_name)
	player_quests[quest.quest_id] = quest
	new_quest_added.emit(quest_name)
	
#Get a quest from the current loaded resource
#Usefull for displaying quest data
func get_quest_from_resource(quest_name= ""):
	var quest_data = {}
	for quest in current_resource.quest_data:
		if current_resource.quest_data[quest].quest_name == quest_name:
			quest_data = current_resource.quest_data[quest]
			break
	assert(!quest_data.is_empty(),"The Quest: %s was not found in loaded resource" % quest_name)
	return quest_data

#Return true if the player currently has a quest
func has_quest(quest_name):
	for i in player_quests:
		if player_quests[i].quest_name == quest_name:
			return true
	return false
func is_quest_complete(quest_name):
	var quest = get_player_quest(quest_name)
	return quest.completed
#get the current step in the quest
func get_current_step(quest_name):
	var quest = get_player_quest(quest_name)
	if quest.step_index >= quest.steps.size():
		print("quest %s was completed. Step index out of bounds" % quest_name)
		return {}
	return quest.steps[quest.step_index]
	

func get_all_steps(quest_name):
	var steps = []
	for quest in player_quests:
		if player_quests[quest].quest_name == quest_name:
			steps = player_quests[quest].steps
			break

func get_meta_data(quest_name):
	var meta_data ={}
	for quest in player_quests:
		if player_quests[quest].quest_name == quest_name:
			meta_data = player_quests[quest].meta_data
			break
	return meta_data
	
#Remove quest from player quests including steps/items and metadata
func remove_quest(quest_name):
	var steps = player_quests.quests[quest_name].steps
	var items = player_quests.quests[quest_name].items
	var metadata = player_quests.quests[quest_name].meta_data
	player_quests.quests.remove(quest_name)
	for i in steps:
		player_quests.steps.remove(i)
	for i in items:
		player_quests.items.remove(i)
	player_quests.meta_data.remove(metadata)

#Gets quest info i.e quest_details from loaded quest resource
func get_quest_info(quest_name):
	return current_resource.quest_data[quest_name].quest_details
	
#Progresses a quest to its next step
#completes quest if it was at its last step
func progress_quest(quest_name:String, quest_item="",amount:int=1):
	var quest_complete = false
	var id = get_player_quest(quest_name).quest_id
	var step = get_current_step(quest_name)
	match step.step_type:
		"action_step":
			step.complete = true
			player_quests[id].step_index += 1
		"incremental_step":
			step.collected += amount
			if step.collected >= step.required:
				player_quests[id].step_index += 1
		"items_step":
			var items = player_quests[id]["item_list"]
			for item in items:
				if item.name == quest_item:
					item.complete = true
			var missing_items = false
			for item in items:
				if item.complete == false:
					missing_items = true
			if missing_items == false:
				player_quests[id].step_index += 1
	var total_steps = player_quests[id].steps.size()
	if player_quests[id].step_index >= total_steps:
		complete_quest(quest_name)

#Completes a quest if every required step was completed
func complete_quest(quest_name):
	var id = get_player_quest(quest_name).quest_id
	player_quests[id].completed = true
	quest_completed.emit(quest_name)

#sets the quests meta data
func set_meta_data(quest_name,meta_data, value:Variant):
	var id = get_player_quest(quest_name).quest_id
	player_quests[id].metadata[meta_data] = value

#Fails a quest
func fail_quest(quest_name):
	var id = get_player_quest(quest_name).quest_id
	player_quests[id].failed = true
	quest_failed.emit(quest_name)
	
#Reset Quest Values
func reset_quest(quest_name):
	var id = get_player_quest(quest_name).quest_id
	player_quests[id].completed = false
	player_quests[id].failed = false
	player_quests[id].step_index = 0
	for step in player_quests[id].steps:
		match step.step_type:
			"action_step":
				step.complete = false
			"incremental_step":
				step.collected = 0
			"items_step":
				for i in step.items_list:
					i.complete = false
#Removes Every Quest from player 
#Usefull for new game files if neccessary
func wipe_quest_data():
	player_quests = {}
