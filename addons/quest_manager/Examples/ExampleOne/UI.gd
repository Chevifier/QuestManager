extends CanvasLayer

@export var quest_name = ""
@export var quest_resource:QuestResource
@onready var quest_info_label = $Do
@onready var life = $HP
enum {
	START,
	RUNNING,
	LOSE,
	WIN
}

var state = START
func _ready():
	state = START
	get_tree().paused = true
	#add the quest to player quests
	QuestManager.add_quest(quest_name,quest_resource)
	#set the quest step initail values
	update_ui(QuestManager.get_current_step(quest_name))
	#Connect quest manager needed signals
	QuestManager.step_updated.connect(update_ui)
	QuestManager.step_complete.connect(update_ui)
	QuestManager.quest_completed.connect(quest_complete)
	QuestManager.quest_failed.connect(quest_failed)
	#set quest detail text 
	$Quest.text = QuestManager.get_player_quest(quest_name).quest_details
	#scale quest label to initailly be 0 for tweening
	$Quest.scale.y = 0
	#Show quest info and start game after tween
	var t = create_tween().chain()
	t.tween_property($Quest,"scale:y",1,0.5)
	t.tween_property($Quest,"scale:y",0,0.5).set_delay(2)
	t.tween_callback(start)

func start():
	state = RUNNING
	get_tree().paused = false
	$Quest.hide()
	
func quest_complete(n,rewards):
	print(rewards)
	state = WIN
	$Complete.text += "\n Money " + str(rewards.money)
	$Complete.show()
	
	get_tree().paused = true
	
func quest_failed(n):
	state = LOSE
	$GameOver.show()
	get_tree().paused = true
	
func update_ui(step):
	match step.step_type:
		QuestManager.INCREMENTAL_STEP:
			var text = "%s %02d/%02d" % [step.details,step.collected,step.required]
			quest_info_label.text = text
		QuestManager.TIMER_STEP:
			var text = "%s %03d" % [step.details,step.time]
			quest_info_label.text = text
func _process(delta):
	if %Player.hp <= 0:
		QuestManager.fail_quest(quest_name)
	match state:
		RUNNING:
			life.text = "LIVES %02d/03" % %Player.hp


func _on_retry_pressed():
	QuestManager.reset_quest(quest_name)
	get_tree().reload_current_scene()


func _on_exit_pressed():
	get_tree().quit()
