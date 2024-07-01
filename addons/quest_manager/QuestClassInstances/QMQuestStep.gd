class_name QMQuestStep extends Node
signal step_complete()

var step = {}

func set_step_data(step_data:Dictionary) -> void:
	step = step_data

func complete_step():
	step.complete = true
	step_complete.emit(step)
	queue_free()
