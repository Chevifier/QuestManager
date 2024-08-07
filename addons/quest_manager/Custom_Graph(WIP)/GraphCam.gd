extends Camera2D
var pan = false
var target_position = Vector2()
func _ready() -> void:
	target_position = position
func _process(delta: float) -> void:

	if pan:
		target_position -= Input.get_last_mouse_velocity() * delta
		
	position = lerp(position,target_position,4*delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			pan = true
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			pan = false
