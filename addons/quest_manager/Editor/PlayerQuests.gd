extends Control
@onready var player_quest_list = %Player_Quests_List
@onready var player_quest_name_lbl = %Player_Quest_Name
@onready var player_quest_description = %Player_Quest_Description

@onready var step_details = %Current_Step_Details
@onready var action_step_btn = %action_step_button
@onready var incremental_step_ctrls = %incremental_step
@onready var item_step_btn = %item_step_button
@onready var controls = %step_controls
var selected_quest = ""

func _ready():
	set_defaults()
	QuestManager.new_quest_added.connect(update_quest_list)
	QuestManager.step_updated.connect(update_current_step)
	QuestManager.step_complete.connect(update_current_step)
	QuestManager.quest_completed.connect(on_quest_complete)
	QuestManager.quest_failed.connect(on_quest_failed)
	
	
func update_quest_list(quest_name):
	player_quest_list.clear()
	for quest in QuestManager.get_all_player_quests_names():
		player_quest_list.add_item(quest)
		
func on_quest_complete(quest_name,rewards:Dictionary):
	step_details.text = "QUEST COMPLETE"
	for control in controls.get_children():
		control.queue_free()
	print(rewards)
func on_quest_failed(n):
	step_details.text = "QUEST FAILED"
	for control in controls.get_children():
		control.queue_free()
		
func update_current_step(step):
	if QuestManager.is_quest_complete(selected_quest):
		step_details.text = "QUEST COMPLETE"
		return
	if QuestManager.is_quest_failed(selected_quest):
		step_details.text = "QUEST FAILED"
		return
	if QuestManager.has_quest(selected_quest)==false:
		return
	step_details.text = step.details
	for node in controls.get_children():
		node.queue_free()
		
	match step.step_type:
		QuestManager.ACTION_STEP:
			var c = action_step_btn.duplicate()
			controls.add_child(c)
			c.pressed.connect(action_button_pressed)
		QuestManager.INCREMENTAL_STEP:
			var c = incremental_step_ctrls.duplicate()
			controls.add_child(c)
			var item_name = step.item_name
			var amount_node = c.get_node("amount")
			c.get_node("add").pressed.connect(add_amount_pressed.bind(item_name,amount_node))
			step_details.text = "%s: %02d/%02d" % [step.details,step.collected,step.required] 
		QuestManager.ITEMS_STEP:
			for i in step.item_list:
				var c = item_step_btn.duplicate()
				controls.add_child(c)
				c.text = i.name
				c.button_pressed = i.complete
				c.toggled.connect(item_completed.bind(c.text))
		QuestManager.TIMER_STEP:
			step_details.text = "%s, \n Time Remaining: %03d"%[step.details,step.time]
			var c = action_step_btn.duplicate()
			controls.add_child(c)
			c.pressed.connect(action_button_pressed)
		QuestManager.BRANCH_STEP:
			var c = action_step_btn.duplicate()
			controls.add_child(c)
			c.pressed.connect(action_button_pressed)
			var d = action_step_btn.duplicate()
			controls.add_child(d)
			d.text = "BRANCH"
			d.pressed.connect(branch_button_pressed)

func action_button_pressed():
	QuestManager.set_branch_step(selected_quest,false)
	QuestManager.progress_quest(selected_quest)

func branch_button_pressed():
	QuestManager.set_branch_step(selected_quest,true)
	QuestManager.progress_quest(selected_quest)

func add_amount_pressed(item_name,node:SpinBox):
	QuestManager.progress_quest(selected_quest,item_name,node.value)
func item_completed(complete,item_name):
	QuestManager.progress_quest(selected_quest,item_name,1,complete)

func _on_player_quests_list_item_selected(index):
	selected_quest = player_quest_list.get_item_text(index)
	var quest = QuestManager.get_player_quest(selected_quest)
	player_quest_name_lbl.text = quest.quest_name
	player_quest_description.text = quest.quest_details
	update_current_step(QuestManager.get_current_step(selected_quest))


func _on_delete_quest_pressed():
	if QuestManager.has_quest(selected_quest):
		#QuestManager.reset_quest(selected_quest)
		QuestManager.remove_quest(selected_quest)
		set_defaults()
		update_quest_list("")
		%accept_quest.disabled = false

func set_defaults():
	player_quest_name_lbl.text = "No Quest Select"
	player_quest_description.text = "No Quest selected"
	step_details.text = "No Quest selected"
	for i in controls.get_children():
		i.queue_free()
	player_quest_list.clear()
	
	
	


func _on_show_data_pressed():
	if selected_quest == "":
		return
	#get quest from player quest because its added to player quest
	var quest = QuestManager.get_player_quest(selected_quest)
	if quest.is_empty():
		return
	if quest["meta_data"].is_empty():
		return
	var quest_data = "Group: %s \nMeta Data \n" % quest.group
	var new_line = 0
	for data in quest.meta_data:
		if new_line%2 == 0:
			quest_data += "%s = %s, " % [data, quest.meta_data[data]]
		else:
			quest_data += "%s = %s \n" % [data, quest.meta_data[data]]
		new_line += 1
	
	%quest_data_label.text = quest_data
	%quest_data.popup_centered()
