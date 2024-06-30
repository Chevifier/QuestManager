class_name QMItemsStep extends QMQuestStep

func collect_item(item_name):
	
	if all_items_collected():
		complete_step()
	pass

func all_items_collected():
	var collected = false
	#TO-DO check all items collected
	return collected
