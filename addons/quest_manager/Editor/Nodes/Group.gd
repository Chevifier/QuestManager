@tool
extends EditorNode

@onready var group = $LineEdit
func setup():
	super.setup()
	Node_Type = Type.GROUP_NODE
	focus_nodes.append(group)

func get_data():
	node_data["group"] = group.text
	super.get_data()
	return node_data

func set_data(data):
	super.set_data(data)
	group.text = data["group"]

func _on_line_edit_text_changed(new_text):
	node_data["text"] = group.text
