extends CanvasLayer

enum {
	RUNNING,
	DIALOGUE
}
var state = RUNNING
var exitpressed = false
func _ready():
	update_incremental_step("Apple",0,10)
	update_items_step("Give a slice to each memeber",["Father","Mother","Sister"])

func _process(delta):
	%Apples.text = "Apples: %02d" % %Player.apples
	match state:
		RUNNING:
			return
		DIALOGUE:
			process_input()

func update_step(discription):
	%discription.text = discription

func update_incremental_step(discription,num,total):
	var details = "%s %02d/%02d" % [discription, num, total]
	%discription.text = details
	
func update_items_step(discription,items:Array):
	%discription.text = discription
	for c in %step.get_children():
		if c.name == "discription":
			continue
		c.queue_free()
	for i in items:
		var item = %item.duplicate()
		%step.add_child(item)
		item.text = i
		item.show()
		
func quest_complete():
	%discription.text = "COMPLETE"
		
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
