extends CanvasLayer

enum {
	RUNNING,
	DIALOGUE
}
var state = RUNNING
var exitpressed = false
func _ready():
	QuestManager.new_quest_added.connect(new_quest)
	QuestManager.step_updated.connect(update_ui)
	QuestManager.step_complete.connect(update_ui)
	QuestManager.quest_completed.connect(quest_complete)
	
func new_quest(n):
	update_ui(QuestManager.get_current_step(n))
	
	
func _process(delta):
	%Apples.text = "Apples: %02d" % %Player.apples
	match state:
		RUNNING:
			return
		DIALOGUE:
			process_input()

func update_ui(step):
	for c in %items.get_children():
		c.free()
	match step.step_type:
		QuestManager.ACTION_STEP:
			%discription.text = step.details
		QuestManager.INCREMENTAL_STEP:
			var text = "%s %02d/%02d" % [step.details, step.collected, step.required]
			%discription.text = text
		QuestManager.ITEMS_STEP:
			%discription.text = step.details
			for item in step.item_list:
				var i = %item.duplicate()
				%items.add_child(i)
				i.text = item.name
				i.button_pressed = item.complete
				i.show()

func quest_complete(n,rewards):
	for c in %items.get_children():
		c.free()
	%discription.text = "QUEST COMPLETE"
func process_input():
	if Input.is_action_just_pressed("ui_accept")and exitpressed == false:
		exitpressed = true
		return
	if Input.is_action_just_pressed("ui_accept"):
		exitpressed = false
		hide_dialogue()
		

func set_text(text):
	$Panel/Dialogue.text = text
	$Panel.show()
	get_tree().paused = true
	state = DIALOGUE
	
func hide_dialogue():
	$Panel.hide()
	get_tree().paused = false
	state = RUNNING
