extends Marker2D

@export var Enemy: PackedScene



func _on_timer_timeout():
	var e = Enemy.instantiate()
	get_parent().add_child(e)
	e.position = Vector2(randf_range(372,800),-30)
