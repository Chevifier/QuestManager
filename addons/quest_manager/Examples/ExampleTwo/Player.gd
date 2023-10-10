extends CharacterBody2D

@export var move_speed = 200
@onready var anim :AnimatedSprite2D = $Sprite
@onready var interact_area = $Interact
@export_category("Controls")
@export var up :=  "ui_up"
@export var down := "ui_down"
@export var left := "ui_left"
@export var right := "ui_right"
@export var interact := "ui_accept"
enum {
	IDLE,
	WALKING
}
var state = IDLE
var apples = 0
var has_pie = false
func _physics_process(delta):
	var dir = Input.get_vector(left,right,up,down)
	velocity = move_speed * dir.normalized()
	if velocity.length() == 0.0:
		state = IDLE
	else:
		state = WALKING
	match state :
		IDLE:
			anim.play("idle")
		WALKING:
			if velocity.y > 1:
				anim.play("walk_down")
			elif velocity.y < -1:
				anim.play("walk_up")
			else:
				anim.play("walk_horizontal")
	
	if velocity.x < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false
	
	move_and_slide()
	
	if Input.is_action_just_pressed(interact):
		talk()
	

func talk():
	var objects = interact_area.get_overlapping_bodies()
	var npc = null
	#get closest object
	var dis = 10000000
	for ob in objects:
		var d = ob.position.distance_to(position)
		if d < dis and ob.is_in_group("NPC"):
			npc = ob
			dis = d
		if ob.is_in_group("stove"):
			if apples >= 10:
				QuestManager.progress_quest(QuestManager.active_quest)
				has_pie = true
	if npc == null:
		return
	
	if npc.family_member == 1 and !QuestManager.has_quest(QuestManager.active_quest): #Mother
		get_parent().get_node("UI").set_text(npc.get_dialogue(0))
		npc.get_quest()

	elif npc.family_member == 1:
		if has_pie == false:
			get_parent().get_node("UI").set_text("Ill be waiting for my slice")
		else:
			QuestManager.progress_quest(QuestManager.active_quest,"Mother")
			get_parent().get_node("UI").set_text("Tasty, Youve outdone yourself")
	else:
		if has_pie == false:
			get_parent().get_node("UI").set_text(npc.get_dialogue(0))
		else:
			if npc.family_member == 0:
				QuestManager.progress_quest(QuestManager.active_quest,"Father")
			elif npc.family_member ==2:
				QuestManager.progress_quest(QuestManager.active_quest,"Sister")
			elif  npc.family_member == 1:
				QuestManager.progress_quest(QuestManager.active_quest,"Mother")
			get_parent().get_node("UI").set_text(npc.get_dialogue(1))











