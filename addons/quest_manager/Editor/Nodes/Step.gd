@tool
extends EditorNode

@onready var details = %details

func setup():
	super.setup()
	focus_nodes.append(details)

func get_data():
	var data = {
		"step_type" : "action_step",
		"details": details.text,
		"complete" : false
	}
	return data

func set_data(data):
	details.text = data["details"]


func _on_details_gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			print("enter")
			details.release_focus()

