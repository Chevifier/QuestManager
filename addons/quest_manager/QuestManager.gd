@tool
extends Node
#Adds each quest as children to be updated
#Each Quest adds its current step add its child

signal quest_completed(quest:Dictionary)
signal quest_failed(quest:Dictionary)
signal step_complete(step:Dictionary)
signal next_step(step:Dictionary)
signal step_updated(step:Dictionary)
signal new_quest_added(quest_name:String)
signal quest_reset(quest_name:String)

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
#For timer step
var counter = 0.0
#get quest to view data
func get_quest_from_resource(quest_name:String,resource:QuestResource=current_resource):
	return resource.get_quest_by_name(quest_name)
#creates all instanced of uncompleted player quests
#loads and add a quest and quest instance to player quests from quest_resource
func add_quest(quest_name:String,resource:QuestResource=current_resource) -> void:
	var node_data = resource.get_quest_by_name(quest_name)
	player_quests[node_data.quest_id] = node_data.duplicate(true)
	new_quest_added.emit(quest_name)
	active_quest = quest_name
	var quest_id = get_quest_id(quest_name)
	var step = get_current_step(quest_id,true)
	step_updated.emit(step)

func load_quest_resource(quest_res:QuestResource) -> void:
	current_resource = quest_res

#Get a quest that the player has accepted
func get_player_quest(quest_name:String,is_id:bool=false) -> Dictionary:
	if is_id:
		return player_quests[quest_name]
	var quest = {}
	for quest_id in player_quests:
		if player_quests[quest_id].quest_name == quest_name:
			quest = player_quests[quest_id]
			break
	return quest


#all the current quests the player has
func get_all_player_quests() -> Dictionary:
	return player_quests
	
func progress_quest_by_name(quest_name,item_name:String="",quantity:int=1,collected:bool=true)->void:
	var quest_id = get_quest_id(quest_name)
	var current_step = get_current_step(quest_id,true)
	progress_quest(quest_id,current_step.id,item_name,quantity,collected)

func progress_quest(quest_id:String,step_id:String, item_name:String="",quantity:int=1,collected:bool=true):
	if has_quest(quest_id,true) == false:
		return
	if player_quests[quest_id].completed == true:
		return
	if player_quests[quest_id].quest_steps.has(step_id) != true:
		return
	var step = player_quests[quest_id].quest_steps[step_id]
	match step.step_type:
		ACTION_STEP:
			complete_step(quest_id,step)
		INCREMENTAL_STEP:
			step.collected += quantity
			step_updated.emit(step)
			if step.collected >= step.required:
				complete_step(quest_id,step)
		ITEMS_STEP:
			var all_item_collected = true
			for item in step.item_list:
				if item.name == item_name:
					item.complete = true
					break
			for item in step.item_list:
				if item.complete == false:
					all_item_collected = false
					break
			step_updated.emit(step)
			if all_item_collected:
				complete_step(quest_id,step)
				
		TIMER_STEP:
			step.completed = true
			complete_step(quest_id,step)
			
		CALLABLE_STEP:
			#call function
			call_function(step.detail,step.params)
			complete_step(quest_id,step)
		BRANCH_STEP:
			step.completed = true
			complete_step(quest_id,step)
		END:
			step_complete.emit(step)
	var next_step = player_quests[quest_id].quest_steps[step.next_id]
	if next_step.step_type == CALLABLE_STEP and step.completed:
		call_function(next_step.details,next_step.params.funcparams)
		complete_step(quest_id,next_step)
	if next_step.step_type == END and step.completed:
		complete_quest(quest_id,true)
#Updates Timer_Steps
func _process(delta):
	if Engine.is_editor_hint():
		return
	counter += delta
	if counter >= 1.0:
		counter = 0.0
		for quest_id in player_quests:
			if player_quests[quest_id].failed or player_quests[quest_id].completed:
				continue
			var current_step = player_quests[quest_id].next_id
			
			var step = player_quests[quest_id].quest_steps[current_step]
			
			if step.is_empty():
				return
			if step.step_type != TIMER_STEP:
				return
			if step.is_count_down:
				step.time -= 1
				if step.time <= 0:
					if step.fail_on_timeout:
						fail_quest(player_quests[quest_id].quest_name)
					else:
						progress_quest(player_quests[quest_id].quest_id,step.id)
			else:
				step.time += 1
				if step.time >= step.total_time:
					if step.fail_on_timeout:
						fail_quest(player_quests[quest_id].quest_name)
					else:
						progress_quest(player_quests[quest_id].quest_id,step.id)
			step_updated.emit(step)

func get_quest_id(quest_name:String)->String:
	var id = ""
	for quest_id in player_quests:
		if player_quests[quest_id].quest_name == quest_name:
			id = quest_id
			break
	return id

#returns all player quests names as array
func get_all_player_quests_names() -> Array:
	var quests = []
	for i in player_quests:
		quests.append(player_quests[i].quest_name)
	return quests
#set if a branch step should branch
func set_branch_step(quest_id,step_id, should_branch:bool=true) -> void:
	var step = player_quests[quest_id].quest_steps[step_id]
	if step.step_type == BRANCH_STEP:
		step.branch = should_branch

#Optionally get quests that were grouped by group name grouped to all by default
func get_quest_list(quest_resource:QuestResource=current_resource, group:String="") -> Dictionary:
	assert(quest_resource != null, "Quest Resource not Loaded")
	return quest_resource.get_quests(group)

func has_quest(quest_name:String,is_id:bool = false)->bool:
	if is_id:
		return player_quests.has(quest_name)
	else:
		for quest in player_quests:
			if player_quests[quest].quest_name == quest_name:
				return true
		return false
#Add a quest that was created from script/at runtime
func add_scripted_quest(quest:ScriptQuest)->void:
	player_quests[quest.quest_data["quest_id"]] = quest.quest_data
	new_quest_added.emit(quest.quest_data.quest_name)
	active_quest = quest.quest_data.quest_name
#return true if quest is complete
func is_quest_complete(quest_name:String,is_id:bool=false) -> bool:
	if is_id:
		if player_quests.has(quest_name):
			return player_quests[quest_name].completed
	var quest = get_player_quest(quest_name,is_id)
	return quest.completed
#returns true if quest was failed
func is_quest_failed(quest_name:String,is_id:bool=false) -> bool:
	var quest = get_player_quest(quest_name,is_id)
	if quest.is_empty():
		return false
	return quest.failed
	
#get the current step in quest
func get_current_step(quest_name:String,is_id = false) -> Dictionary:
	if is_id:
		var next_id = player_quests[quest_name].next_id
		return player_quests[quest_name].quest_steps[next_id]
	var quest = get_player_quest(quest_name,is_id)
	return quest.quest_steps[quest.next_id]

#Remove quest from player quests including steps/items and metadata
func remove_quest(quest_name:String) -> void:
	for i in player_quests:
		if player_quests[i].quest_name == quest_name:
			player_quests.erase(i)
			
func get_quest_steps_from_resource(quest_name,quest_res:QuestResource=current_resource) -> Array:
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
	
func complete_step(quest_id:String,step:Dictionary):
	step.completed = true
	step_complete.emit(step)
	var next_id = step.next_id
	if step.step_type == BRANCH_STEP:
		if step.branch:
			next_id = step.branch_step_id
		else:
			next_id = step.next_id
	player_quests[quest_id].next_id = next_id
	next_step.emit(player_quests[quest_id].quest_steps[next_id])
#Completes a quest if every required step was completed
func complete_quest(quest_name:String,is_id:bool = false) -> void:
	if is_id:
		player_quests[quest_name].completed = true
	else:
		get_player_quest(quest_name).completed = true
	#emits quest dictionary
	
	quest_completed.emit(get_player_quest(quest_name,is_id))

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
func fail_quest(quest_name:String,is_id=false) -> void:
	var quest = get_player_quest(quest_name,is_id)
	quest.failed = true
	quest_failed.emit(quest)
	
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
	

#helper function to save player data
func get_save_quest_data() -> Dictionary:
	return player_quests
#helper function to load player data
func load_saved_quest_data(data:Dictionary) -> void:
	player_quests = data.duplicate(true)
#Removes Every Quest from player 
#Usefull for new game files if neccessary
func wipe_player_data() -> void:
	player_quests = {}


func testfunc(v:Array=[]):
	print("Hello QuestManager "+str(v))

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
