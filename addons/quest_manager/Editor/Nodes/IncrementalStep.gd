@tool
extends EditorNode

@onready var details = %details
@onready var quantity = %quantity

func setup():
	super.setup()
	focus_nodes.append(details)
	focus_nodes.append(quantity)
	
#returns an array with both the stored data and node position and name data
func get_data():
	var data = {
		"step_type":"incremental_step",
		"details" : details.text,
		"required" : quantity.value,
		"collected" : 0
	}

	return [data,get_node_data()]
	
func set_data(data):
	details.text = data[0].details
	quantity.value = data[0].required

func _on_details_gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			print("enter")
			details.release_focus()
