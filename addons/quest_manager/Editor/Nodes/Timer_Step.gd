@tool
extends EditorNode

@onready var details = %details
@onready var minutes_node = %minutes
@onready var seconds_node = %seconds
@onready var count_dir = %count_dir
@onready var fail_toggle = %fail_on_timeout
func setup():
	super.setup()
	focus_nodes.append(details)

func get_data():
	var data = {
		"step_type" : "timer_step",
		"details": details.text,
		"total_time": get_time_in_seconds(),
		"time" : get_time(count_dir.button_pressed),
		"is_count_down" : count_dir.button_pressed,
		"fail_on_timeout" : fail_toggle.button_pressed,
		"time_minutes": minutes_node.value,
		"time_seconds": seconds_node.value
	}
	return data
func set_data(data):
	details.text = data["details"]
	minutes_node.value = data["time_minutes"]
	seconds_node.value = data["time_seconds"]
	count_dir.button_pressed = data["is_count_down"]
	fail_toggle.button_pressed = data["fail_on_timeout"]

func _on_details_gui_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			details.release_focus()
func get_time(dir):
	if dir:
		return get_time_in_seconds()
	else:
		return 0
func get_time_in_seconds():
	var seconds = 0
	for i in minutes_node.value:
		seconds += 60
	seconds += seconds_node.value
	return seconds

func _on_count_down_toggled(button_pressed):
	if button_pressed:
		count_dir.text = "Timer"
	else:
		count_dir.text = "Stop Watch"

func _on_fail_on_timeout_toggled(button_pressed):
	if button_pressed:
		fail_toggle.text = "Fail On Timeout"
	else:
		fail_toggle.text = "Complete On Timeout"
