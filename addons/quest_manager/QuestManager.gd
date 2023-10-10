@tool
extends Node

signal quest_completed(quest_name)
signal quest_failed(quest_name)
signal step_complete(quest_name)
signal step_updated(quest_name)
signal new_quest_added(quest_name)
signal quest_reset(quest_name)

const ACTION_STEP = "action_step"
const INCREMENTAL_STEP = "incremental_step"
const ITEMS_STEP = "items_step"
const TIMER_STEP = "timer_step"
const BRANCH_STEP = "branch_step"
const CALLABLE_STEP = "callable_step"
const END = "end"
#Helper variable for searching for quest
var active_quest = ""

var current_resource:QuestResource
var player_quests = {}
#---TIMER_STEP VARIABLE-------
var counter = 0.0
#used to update timer steps individually

#get quest to view data
func get_quest_from_resource(quest_name:String,resource:QuestResource=current_resource):
	return resource.get_quest_by_name(quest_name)

#loads and add a quest to player quests from quest_resource
func add_quest(quest_name:String,resource:QuestResource=current_resource) -> void:
	var node_data = resource.get_quest_by_name(quest_name)
	player_quests[node_data.quest_id] = node_data.duplicate(true)
	new_quest_added.emit(quest_name)
	active_quest = quest_name
	step_updated.emit(get_current_step(quest_name))

func load_quest_resource(quest_res:QuestResource) -> void:
	current_resource = quest_res

#Get a quest that the player has accepted
func get_player_quest(quest_name:String,is_id:bool=false) -> Dictionary:
	if is_id:
		return player_quests[quest_name]
	var node_data = {}
	for quest in player_quests:
		if player_quests[quest].quest_name == quest_name:
			node_data = player_quests[quest]
			break
	return node_data

#all the current quests the player has
func get_all_player_quests() -> Dictionary:
	return player_quests
	
#returns all player quests names as array
func get_all_player_quests_names() -> Array:
	var quests = []
	for i in player_quests:
		quests.append(player_quests[i].quest_name)
	return quests
	
func set_branch_step(quest_name, should_branch:bool=true) -> void:
	var step = get_current_step(quest_name)
	if step.step_type == BRANCH_STEP:
		get_current_step(quest_name)["branch"] = should_branch
		
#Progresses a quest to its next step
#completes quest if it was at its last step
func progress_quest(quest_name:String, quest_item:String="",amount:int=1,completed:bool=true, branch:bool=false) -> void:
	quest_error(quest_name)
	active_quest = quest_name
	if is_quest_complete(quest_name):
		return
	var id = get_player_quest(quest_name).quest_id
	var step = get_current_step(id,true)
	match step.step_type:
		ACTION_STEP:
			get_current_step(id,true).complete = completed
			player_quests[id].next_id = step["next_id"]
			step_complete.emit(get_current_step(id,true))
		INCREMENTAL_STEP:
			assert(step.item_name == quest_item,"Item: %s invalid" % quest_item)
			get_current_step(id,true).collected += amount
			step_updated.emit(get_current_step(id,true))
			if step.collected >= step.required:
				player_quests[id].next_id = step["next_id"]
				step_complete.emit(get_current_step(id,true))
		ITEMS_STEP:
			for item in get_current_step(id,true).item_list:
				if item.name == quest_item:
					item.complete = true
					step_updated.emit(get_current_step(id,true))
					break
			var missing_items = false
			for item in get_current_step(quest_name).item_list:
				if item.complete == false:
					missing_items = true
					step_updated.emit(get_current_step(id,true))
					break
			if missing_items == false:
				get_current_step(id,true).complete = true
				player_quests[id].next_id = step["next_id"]
				step_complete.emit(get_current_step(id,true))
		TIMER_STEP:
			if quest_item != "":
				#prevents progress quest calls that contains item
				return
			player_quests[id].next_id = step["next_id"]
			step_complete.emit(get_current_step(id,true))
		#Checks condition and decides if it should branch
		BRANCH_STEP:
			if get_current_step(id,true).branch == false:
				player_quests[id].next_id = get_current_step(id,true)["next_id"]
			else:
				player_quests[id].next_id = get_current_step(id,true)["branch_step_id"]
			get_current_step(id,true)["complete"] = true
			step_complete.emit(get_current_step(id,true))
	#get updated step
	step = get_current_step(id,true)
	#call function if the step is a callable step then move to next function
	if step.step_type == CALLABLE_STEP:
		call_function(step.callable,step.params["funcparams"])
		get_current_step(id,true)["complete"] = true
		player_quests[id].next_id = step["next_id"]
		step_complete.emit(get_current_step(id,true))
	#Ends the quest
	if step.step_type == END:
		get_player_quest(id,true).completed = true
		complete_quest(id,true)
		step_updated.emit(step)

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
				get_current_step(quest_name).collected = amount
				
		ITEMS_STEP:
			for item in step.item_list:
				if item.name == quest_item:
					get_current_step(quest_name).complete = collected
					step_updated.emit(get_current_step(quest_name))
	step_updated.emit(step)

#Optionally get quests that were grouped by group name grouped to all by default
func get_quest_list(quest_resource:QuestResource=current_resource, group:String="") -> Dictionary:
	assert(quest_resource != null, "Quest Resource not Loaded")
	return quest_resource.get_quests(group)
	
#Add a quest that was created from script/at runtime
func add_scripted_quest(quest:ScriptQuest):
	player_quests[quest.quest_data["quest_id"]] = quest.quest_data
	new_quest_added.emit(quest.quest_data.quest_name)
	active_quest = quest.quest_data.quest_name

#Return true if the player currently has a quest
func has_quest(quest_name:String,is_id:bool = false) -> bool:
	if is_id:
		if player_quests.has(quest_name):
			return true
	for i in player_quests:
		if player_quests[i].quest_name == quest_name:
			return true
	return false
#Returns all the player quests that are not
#completed or have not been failed
func get_quests_in_progress():
	var active_quests = {}
	for quest in player_quests:
		if player_quests[quest].failed or player_quests[quest].completed:
			continue
		active_quests[quest] = player_quests[quest]
	return active_quests
	
#return true if quest is complete
func is_quest_complete(quest_name:String,is_id:bool=false) -> bool:
	if is_id:
		if player_quests.has(quest_name):
			return player_quests[quest_name].completed
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
func get_current_step(quest_name:String,is_id:bool=false) -> Dictionary:
	if is_id:
		var next_id = player_quests[quest_name].next_id
		return player_quests[quest_name]["quest_steps"][next_id]

	if has_quest(quest_name)==false:
		return {}
	if is_quest_complete(quest_name):
		return {}
	var quest = get_player_quest(quest_name)
	return quest.quest_steps[quest.next_id]

#Remove quest from player quests including steps/items and metadata
func remove_quest(quest_name:String) -> void:
	for i in player_quests:
		if player_quests[i].quest_name == quest_name:
			player_quests.erase(i)
			
func get_quest_steps_from_resource(quest_name,quest_res:QuestResource=current_resource):
	return current_resource.get_quest_steps_sorted(quest_name)
#returns a dictionary of all the rewards of a player quest
func get_quest_rewards(quest_name:String,id_id:bool=false) -> Dictionary:
	var quest_rewards ={}
	if id_id:
		quest_rewards = player_quests[quest_name].quest_rewards
		return quest_rewards
	for quest in player_quests:
		if player_quests[quest].quest_name == quest_name:
			quest_rewards = player_quests[quest].quest_rewards
			break
	return quest_rewards
	
#Completes a quest if every required step was completed
func complete_quest(quest_name:String,is_id:bool = false) -> void:
	if is_id:
		player_quests[quest_name].completed = true
	else:
		get_player_quest(quest_name).completed = true
	#emits quest name and rewards dictionary
	quest_completed.emit(quest_name,get_quest_rewards(quest_name,is_id))

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
	player_quests[id].next_id = player_quests[id].first_step
	for step in player_quests[id].quest_steps:
		var replace_step = player_quests[id].quest_steps[step]
		match replace_step.step_type:
			ACTION_STEP:
				replace_step.complete = false
			INCREMENTAL_STEP:
				replace_step.collected = 0
			ITEMS_STEP:
				for i in replace_step.items_list:
					replace_step.item_list[i].complete = false
			TIMER_STEP:
				if replace_step.is_count_down:
					replace_step.time = replace_step.total_time
				else:
					replace_step.time = 0
			BRANCH_STEP:
				replace_step.branch = false
		player_quests[id].quest_steps[step] = replace_step
	quest_reset.emit(quest_name)
	
#Removes Every Quest from player 
#Usefull for new game files if neccessary
func wipe_node_data() -> void:
	player_quests = {}


func call_function(autoloadfunction:String,params:Array) -> void:
	#split function from autoload script name
	var autofuncsplit = autoloadfunction.split(".")
	var singleton_name = autofuncsplit[0]
	var function = autofuncsplit[1]
	#get only function name without ()
	var callable = function.split("(")[0]
	#Autoload name needs to be the same as script or use name of Node instead.
	assert(Engine.has_singleton(singleton_name)==false, "Singleton %s Not Loaded or invalid" % singleton_name)
	var auto_load = get_tree().root.get_node(singleton_name)
	#if array has values pass array otherwise call function normally
	if params.size()>0:
		auto_load.call(callable,params)
	else:
		auto_load.call(callable)
		
func testfunc(v:Array=[]):
	print("Hello QuestManager "+str(v))

func quest_error(quest_name:String) -> void:
	assert(has_quest(quest_name),"Player doesnt have quest %s added to the player_quest Dictionary or case?" % quest_name)
