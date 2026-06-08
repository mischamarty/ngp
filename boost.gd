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

func _on_body_entered(body):
	if body.name == "Player":
		body.add_boost(30)
		if position.x < 195 and body.has_user_signal("wrong_lane_boost_collected"):
			body.emit_signal("wrong_lane_boost_collected")
		elif position.x < 195:
			# Fallback if signal isn't registered via has_user_signal for built-in
			body.emit_signal("wrong_lane_boost_collected")

		# Play sound
		var audio = AudioStreamPlayer.new()
		audio.stream = preload("res://boost.wav")
		# Connect to finished signal to automatically free the audio node
		audio.connect("finished", Callable(audio, "queue_free"))
		get_parent().add_child(audio)
		audio.play()
		# delete self now
		queue_free()