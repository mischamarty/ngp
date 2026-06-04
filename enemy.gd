extends Area2D

var speed = 200.0

func _process(delta):
	position.y += speed * delta

	if position.y > 900: # Assuming screen height is 800, delete when off screen
		queue_free()