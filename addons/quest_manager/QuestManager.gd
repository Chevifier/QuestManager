extends Node

signal quest_progressed()
signal quest_item_collected()
signal quest_failed()
signal quest_completed()
signal quest_reset()

var quests_data = {
	"231456a" : {
		"name": "Stronger than Family",
		"details" : "Your Parents are in Peril, Get 10 coins and give them to your mom and dad",
		"completed" : false,
		"failed" : false,
		"step_index" : 0,
		"group": "",
		"step_ids" : ["645313","323412","457355"],
		"metadata": "342424"
		}
	}
var steps_list = {
		"645313" : {
		"type" : "action_step",
		"details":"reach location",
		"complete":false
		},
		"323412" : {
		"type" : "incremental_step",
		"details":"collect 10 coins",
		"required": 10,
		"collected": 0
		},
		"447355" : {
		"type" : "items_step",
		"details":"give 5 coins to mother and 5 to father",
		"item_list" : ["342212","539347"]
		}
	}
var items_list = {
	"342212" : {
		"name":"5 for mother",
		"complete": false
	},
	"539347" : {
		"name":"5 for father",
		"complete" : false
	}
	}
var meta_data = {
	"342424" : {
		"coins" : 100
	}
	}

var player_quests = {}
func _ready():
	pass
#all the current quests the player has


#returns every quest created
#Optionally get quests that were grouped by group name grouped to all by default
func get_quest_list(QuestResource, group ="all"):
	return {}

#Adds quest to the quest list
func add_quest(quest_name, id = ""):
	var quest #Get Quest dictionary
	#TO_Do check if id is given first if not search by name
	if id != "":
		player_quests
	player_quests[quest_name] = quest
	#print(player_quests)
	
func remove_quest(quest_name, id= ""):
	#Remove quest from player quests
	#also remove steps and items_steps
	pass

#gets quest info i.e details
func get_quest_info(quest:String):
	return player_quests[quest].details

#Progresses a quest to its next step
#completes quest it was at its last step
func progress_quest(quest:String,amount:int=1):
	player_quests[quest].step_index += amount
	quest_progressed.emit(quest)
	var total_steps = player_quests[quest].steps.size()
	if player_quests[quest].step_index == total_steps:
		complete_quest(quest)
	#To do check if step greater than total steps
	pass
	
#Collect item(s) required to progress_quest
#Once all items are collected progress_quest is called automatically
func collect_quest_item(quest_id:String,item_id:String,auto_progress = true):
	pass

#Completes a quest if every required step was completed
func complete_quest(quest):
	player_quests[quest].completed = true
	quest_completed.emit(quest)
	pass

#get meta data of quest
func get_meta_data(quest,meta_data):
	var data
	return data
	
#sets the quests meta data
func set_meta_data(quest,meta_data, value:Variant):
	pass

#Fails a quest
func fail_quest(quest):
	player_quests[quest].failed = true
	quest_failed.emit(quest)
	pass
	
#Reset Quest Values
func reset_quest(quest):
	#reload and overwrite quest
	pass
