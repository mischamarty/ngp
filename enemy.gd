extends Area2D

var speed = 200.0
var direction = 1
var main_node = null

func _process(delta):
	var player_speed = 300.0
	if main_node and main_node.has_node("Player") and not main_node.game_over:
		player_speed = main_node.get_node("Player").speed

	if rotation == 0:
		# Oncoming traffic: speed of car + speed of road (player speed)
		position.y += (speed + player_speed) * delta
	else:
		# Same direction traffic: road speed (player speed) - car speed
		position.y += (player_speed - speed) * delta

	# Despawn if off-screen (bottom or top)
	if position.y > 950 or position.y < -200:
		queue_free()