extends Node

func print_text():
	print("Hello World!")

func _ready():
	var quest = ScriptQuest.new("Test_Quest", "Details")
	quest.add_action_step("Step1")
	quest.add_callable_step("Test.func")
	quest.add_incremental_step("Inc Step", "Coin", 10)
	quest.add_items_step("Items Step", ["item1", "item2", "item3"])
	quest.add_quest_to_group("test_group")
	quest.add_timer_step("Timer Step",10)
	quest.finalize_quest()
