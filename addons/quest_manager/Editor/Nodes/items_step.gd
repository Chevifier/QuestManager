@tool
extends EditorNode

@onready var details = %details
@onready var list:ItemList = %list
@onready var item_to_add = %ItemEdit

var items = []
var last_selected = -1
func setup():
	super.setup()
	focus_nodes.append(details)
	focus_nodes.append(list)
	focus_nodes.append(item_to_add)

#Returns All added items for processing
func get_data():
	var data = {
		"step_type" : "items_step",
		"details": details.text,
		"item_list": items
	}
	return data

func get_items():
	return items
	
func set_data(data):
	details.text = data.details
	for item in data.item_list:
		list.add_item(item.name)

func _on_add_pressed():
	if item_to_add.text == "":
		print("Add item name")
		return
	for item in items:
		if item_to_add.text == item["name"]:
			print("Item already added")
			return
	
	list.add_item(item_to_add.text)
	items.append({
		"name" : item_to_add.text,
		"complete" : false
		})
	item_to_add.clear()
	
func _on_remove_pressed():
	items.remove_at(last_selected)
	list.remove_item(last_selected)
	last_selected = -1

func _on_list_item_selected(index):
	last_selected = index
