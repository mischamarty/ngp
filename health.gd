extends Area3D

var main_node = null

func _physics_process(delta):
	var player_speed = 20.0
	if main_node and main_node.has_node("Player") and not main_node.game_over:
		player_speed = main_node.get_node("Player").speed

	position.z += player_speed * delta

	if position.z > 5:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("heal"):
			body.heal(1)

		# Play a generic pickup sound or boost sound for now
		var audio = AudioStreamPlayer3D.new()
		audio.stream = preload("res://boost.wav")
		audio.connect("finished", Callable(audio, "queue_free"))
		get_parent().add_child(audio)
		audio.play()

		queue_free()