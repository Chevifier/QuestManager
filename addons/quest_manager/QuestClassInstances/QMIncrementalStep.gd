class_name QMIncrementalStep extends QMQuestStep

var collected = 0
var required = 999
var item_name = ""

func item_collected(item_name,amount:=1):
	if step.item_name == item_name:
		step.collected += amount
		if step.collected >= step.collected:
			complete_step()
