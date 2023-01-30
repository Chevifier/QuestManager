extends Node

signal quest_progressed()
signal quest_item_collected()
signal quest_failed()
signal quest_completed()
signal quest_reset()

var quests_data = {
	"231456a" : {
		"name": "Theres Nothing Stronger than Family",
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
func add_quest(quest:Dictionary):
	player_quests[quest.name] = quest
	#print(player_quests)
	
func remove_quest(quest:String):
	#Remove quest from player quests
	pass

#gets quest of name
func get_quest_info(quest:String):
	return player_quests[quest]

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
	
#Collects an item required to progress_quest
#Can be multiple items
#Once all items are collected progress_quest is called automatically
func collect_quest_item(quest:String,item_name:String,auto_progress = true):
	var step = player_quests[quest].step_index
	quest_item_collected.emit(quest,item_name)
	assert(player_quests[quest].steps[step].type != "item_step","This Quest step is not an Item Step")
	player_quests[quest].steps[step].item_list[item_name] = true
	var item_list = player_quests[quest].steps[step].item_list
	for item in item_list:
		if item_list[item] == false:
			return
	if auto_progress:
		progress_quest(quest)


#Completes a quest if every required step was completed
func complete_quest(quest):
	player_quests[quest].completed = true
	quest_completed.emit(quest)
	pass

#Fails a quest if call
#i.e Reset the quest step to 1
func fail_quest(quest):
	player_quests[quest].failed = true
	quest_failed.emit(quest)
	pass
	
func reset_quest(quest):
	#reload and overwrite quest
	pass
