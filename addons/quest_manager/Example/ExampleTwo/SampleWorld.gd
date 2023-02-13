extends Node2D

@export var enter_pos : Marker2D
@export var exit_pos : Marker2D
func _on_house_enter_body_entered(body):
	if body.name == "Player":
		body.position = enter_pos.position

func _on_house_exit_body_entered(body):
	if body.name == "Player":
		body.position = exit_pos.position
		
