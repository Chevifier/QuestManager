class_name QMItemsStep extends QMQuestStep

func collect_item(item_name):
	for i in step.item_list:
		if step.item_list[i].name == item_name:
			step.item_list[i].complete = true
			break
	if all_items_collected():
		complete_step()

func all_items_collected():
	var collected = true
	for i in step.item_list:
		if step.item_list[i].complete == false:
			collected = false
			break
	#TO-DO check all items collected
	return collected
