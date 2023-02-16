extends CharacterBody2D

@export var left := "ui_left"
@export var right := "ui_right"
@export var shoot := "ui_accept"
const SPEED = 400
var hp = 3
@export var projectile :PackedScene
func _ready():
	hp = 3
	
func _physics_process(delta):
	var dir = Input.get_axis(left,right)
	
	velocity.x = dir * SPEED
	move_and_slide()
	
	if position.x <= 372:
		position.x = 373
	if position.x >= 800:
		position.x = 799
	
	if Input.is_action_just_pressed(shoot):
		fire_pojectile()
	
func fire_pojectile():
	var p = projectile.instantiate()
	get_parent().add_child(p)
	p.position = position
func take_damage():
	hp -= 1
func fly_away_n_exit():
	velocity.y = -500
	if position.y < -10:
		get_tree().quit()
