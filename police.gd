extends Area2D

var speed = 400.0 # Much faster than the player
var main_node = null
var is_siren_red = true

func _ready():
	# Wait for the timer to connect
	pass

func _process(delta):
	var player_speed = 300.0
	if main_node and main_node.has_node("Player") and not main_node.game_over:
		player_speed = main_node.get_node("Player").speed

	# Police car comes from behind, so it's in the same direction but faster
	# It moves up the screen faster than the road goes down
	position.y += (player_speed - speed) * delta

	if position.y < -150: # Destroy when it gets far ahead
		queue_free()

func _on_siren_timer_timeout():
	is_siren_red = !is_siren_red
	if is_siren_red:
		$Visuals/SirenLeft.color = Color(1, 0, 0, 1) # Red
		$Visuals/SirenRight.color = Color(0, 0, 1, 0.3) # Dim blue
	else:
		$Visuals/SirenLeft.color = Color(1, 0, 0, 0.3) # Dim red
		$Visuals/SirenRight.color = Color(0, 0, 1, 1) # Blue