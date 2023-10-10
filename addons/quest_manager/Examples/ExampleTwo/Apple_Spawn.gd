extends Marker2D

@export var Apple : PackedScene


var apple_count = 0
const max_apples = 3

func _ready():
	$Timer.wait_time = randf_range(5,15)
	$Timer.start()
	
func notify_collected():
	apple_count -= 1
	if apple_count < max_apples:
		$Timer.start()

func _spawn_apple():
	var apple = Apple.instantiate()
	add_child(apple)
	var offset = Vector2(randf_range(-96,96),randf_range(-96,96))
	apple.position = offset
	apple_count += 1
	if apple_count >= max_apples:
		$Timer.stop()
	
