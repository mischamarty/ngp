extends Area2D

var speed = 0.0 # Boosts are stationary on the road
var main_node = null

func _process(delta):
	var player_speed = 300.0
	if main_node and main_node.has_node("Player") and not main_node.game_over:
		player_speed = main_node.get_node("Player").speed

	# Move towards the player at the speed of the road
	position.y += player_speed * delta

	if position.y > 900:
		queue_free()