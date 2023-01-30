@tool
extends EditorNode

@onready var details = %details
@onready var list:ItemList = %list
@onready var item_to_add = %ItemEdit

var items = {}
var last_selected = -1

#Returns All added items for processing
func get_data():
	var item_ids = []
	for i in items:
		item_ids.append(i)
		
	var data = {
		"step_type" : "items_step",
		"details": details.text,
		"item_list": item_ids
	}
	return data

func get_items():
	return items
	
func set_data(data):
	print(data)
	details.text = data.details
	
	for item in data.items:
		list.add_item(data.items[item].name)
		list.set_item_metadata(list.item_count-1,data.items[item].id)

func _on_add_pressed():
	if item_to_add.text == "":
		print("Add item name")
		return
	var id = get_random_id()
	list.add_item(item_to_add.text)
	list.set_item_metadata(list.item_count-1,id)
	print(list.get_item_metadata(list.item_count-1))
	items[id] = {
		"id" : id,
		"name" : item_to_add.text,
		"complete" : false
	}
	item_to_add.clear()
	print(items)
	
func _on_remove_pressed():
	items.erase(list.get_item_metadata(last_selected))
	list.remove_item(last_selected)
	last_selected = -1
	print(items)

func _on_list_item_selected(index):
	last_selected = index
