@tool
extends EditorNode

@onready var details = %details
@onready var list:ItemList = %list
@onready var item_to_add = %ItemEdit

var item_list = []
var last_selected = -1
func setup():
	super.setup()
	Node_Type = Type.ITEM_STEP_NODE
	focus_nodes.append(details)
	focus_nodes.append(list)
	focus_nodes.append(item_to_add)

#Returns All added items for processing
func get_data():
	node_data["step_type"] = "items_step"
	node_data["details"]= details.text
	node_data["item_list"]= item_list
	node_data["complete"] = false
	node_data["meta_data"]= get_meta_data()
	super.get_data()
	return node_data

func get_items():
	return item_list
	
func set_data(data):
	super.set_data(data)
	details.text = data.details
	item_list = data.item_list
	for item in data.item_list:
		list.add_item(item.name)

func _on_add_pressed():
	if item_to_add.text == "":
		print("Add item name")
		return
	for item in item_list:
		if item_to_add.text == item["name"]:
			print("Item already added")
			return
	
	list.add_item(item_to_add.text)
	item_list.append({
		"name" : item_to_add.text,
		"complete" : false
		})
	item_to_add.clear()
	print(item_list)
	
func _on_remove_pressed():
	var item_name = list.get_item_text(last_selected)
	for i in range(item_list.size()):
		var item = item_list[i]
		if item.name == item_name:
			item_list.remove_at(i)
			break
	list.remove_item(last_selected)
	last_selected = -1
	print(item_list)

func _on_list_item_selected(index):
	last_selected = index
