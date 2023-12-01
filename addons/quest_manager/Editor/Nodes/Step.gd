@tool
extends EditorNode

@onready var details = %details

func setup():
	Node_Type = Type.STEP_NODE
	focus_nodes.append(details)
	super.setup()

func get_data():
	node_data["step_type"] = "action_step"
	node_data["details"] = details.text
	node_data["meta_data"] = get_meta_data()
	node_data["complete"] = false
	super.get_data()
	return node_data

func set_data(data):
	super.set_data(data)
	details.text = data["details"]

func _on_details_gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			details.release_focus()
