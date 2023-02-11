extends CanvasLayer

@export var quest:QuestResource
@onready var quest_info_label = $Do
@onready var life = $HP
const quest_name = "ShootEmUp"
enum {
	RUNNING,
	LOSE,
	WIN
}

var state = RUNNING
func _ready():
	state = RUNNING
	get_tree().paused = false
	QuestManager.load_quest_resource(quest)
	QuestManager.add_quest(quest_name)

func _process(delta):
	if QuestManager.is_quest_complete(quest_name):
		state = WIN
	if %Player.hp <= 0:
		state = LOSE
	match state:
		RUNNING:
			life.text = "LIVES %02d/03" % %Player.hp
			var step = QuestManager.get_current_step(quest_name)
			var text = "%s %02d/%02d" % [step.details,step.collected,step.required]
			quest_info_label.text = text
		WIN:
			$Complete.show()
			get_tree().paused = true
		LOSE:
			$GameOver.show()
			get_tree().paused = true

func _on_retry_pressed():
	QuestManager.reset_quest(quest_name)
	get_tree().reload_current_scene()


func _on_exit_pressed():
	get_tree().quit()
