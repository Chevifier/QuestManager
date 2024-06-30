extends QMQuestStep

var counter := 0.0

func _process(delta):
	if Engine.is_editor_hint():
		return
	counter += delta
	if counter >= 1.0:
		if step.is_count_down:
			step.time -= 1
			if step.time <= 0:
				if step.fail_on_timeout:
					QuestManager.fail_quest(quest_id)
				else:
					#load next step
					pass
			else:
				step.time += 1
				if step.time >= step.total_time:
					if step.fail_on_timeout:
						QuestManager.fail_quest(quest_id)
					else:
						#load next step
						pass
		counter = 0.0
	
