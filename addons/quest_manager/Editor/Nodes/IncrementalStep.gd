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
	
#returns an array with both the stored data and node position and name data
func get_data():
	var data = {
		"step_type":"incremental_step",
		"details" : details.text,
		"item_name" : item_name.text,
		"required" : quantity.value,
		"collected" : 0,
		"meta_data" : get_meta_data()
	}

	return data
	
func set_data(data):
	details.text = data.details
	item_name.text = data.item_name
	quantity.value = data.required

func _on_details_gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			item_name.release_focus()
			details.release_focus()
