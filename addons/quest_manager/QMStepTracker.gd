@tool
class_name QMStepTracker extends Node
#for use as child on area nodes
#call _update_step 
#get step id from QuestManager Quests Window
enum Step_Type {
	ACTION_STEP,
	INCREMENTAL_STEP,
	ITEM_STEP,
	BRANCH,
	TIMER_STEP,
	CALLABLE,
	END
	
}

@export var step_type :Step_Type = 0:
	set(v):
		step_type = v
		notify_property_list_changed()

@export var quest_id = "12345abc"
@export var step_id = "123456abc"

var item_name = ""
var quantity = 1
var is_branching = false


func update_step():
	if step_type == Step_Type.BRANCH:
		QuestManager.set_branch_step(quest_id,is_branching)
	QuestManager.progress_quest(quest_id,step_id,item_name,quantity)

func _get_property_list() -> Array:
	var quest_id_usage = PROPERTY_USAGE_NO_EDITOR
	var item_name_usage = PROPERTY_USAGE_NO_EDITOR
	var quantity_usage = PROPERTY_USAGE_NO_EDITOR
	var is_branching_usage = PROPERTY_USAGE_NO_EDITOR
	if step_type == Step_Type.ITEM_STEP:
		item_name_usage = PROPERTY_USAGE_DEFAULT
	if step_type == Step_Type.INCREMENTAL_STEP:
		quantity_usage = PROPERTY_USAGE_DEFAULT
	if step_type == Step_Type.BRANCH:
		is_branching_usage = PROPERTY_USAGE_DEFAULT
	var properties = []
	properties.append({
		"name": "item_name",
		"type": TYPE_STRING,
		"usage": item_name_usage
		})
	properties.append({
		"name": "quantity",
		"type": TYPE_INT,
		"usage": quantity_usage
		})
	properties.append({
		"name": "is_branching",
		"type": TYPE_BOOL,
		"usage": is_branching_usage
		})
	return properties
