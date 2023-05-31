@tool
extends EditorNode

@onready var group = $LineEdit
func setup():
	super.setup()
	focus_nodes.append(group)

func get_data():
	return group.text

func set_data(data):
	group.text = data

func _on_line_edit_text_changed(new_text):
	node_data["text"] = group.text
