@tool
extends EditorNode

func setup():
	super.setup()
	Node_Type = Type.END_NODE

func get_data():
	node_data["step_type"] = "end"
	node_data["details"] = "Complete"
	super.get_data()
	return node_data
