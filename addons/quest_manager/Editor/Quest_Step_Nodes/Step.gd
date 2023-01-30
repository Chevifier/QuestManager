@tool
extends EditorNode

@onready var details = %details

func get_data():
	var data = {
		"type" : "action_step",
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

