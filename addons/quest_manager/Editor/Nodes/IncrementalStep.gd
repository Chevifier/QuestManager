@tool
extends EditorNode

@onready var details = %details
@onready var item_name = %item_name
@onready var quantity = %quantity

func setup():
	super.setup()
	Node_Type = Type.INCREMENTAL_NODE
	focus_nodes.append(details)
	focus_nodes.append(quantity)
	
func propogate_quest_id(id):
	if output_node != null:
		output_node.propogate_quest_id(id)

func get_data():
	node_data["step_type"] = "incremental_step"
	node_data["details"] = details.text
	node_data["item_name"] = item_name.text
	node_data["required"] = quantity.value
	node_data["collected"] = 0
	node_data["complete"] = false
	node_data["meta_data"] = get_meta_data()
	super.get_data()
	return node_data
	
func set_data(data):
	super.set_data(data)
	details.text = data.details
	item_name.text = data.item_name
	quantity.value = data.required

func _on_details_gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			item_name.release_focus()
			details.release_focus()
