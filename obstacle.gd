extends Area2D

var speed = 0.0 # Stationary on grass
var main_node = null

func _process(delta):
	var player_speed = 300.0
	if main_node and main_node.has_node("Player") and not main_node.game_over:
		player_speed = main_node.get_node("Player").speed

	position.y += player_speed * delta

	if position.y > 900:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("enemies"):
		# Spawn explosion
		var explosion_scene = load("res://explosion.tscn")
		if explosion_scene:
			var explosion = explosion_scene.instantiate()
			explosion.position = position
			get_parent().add_child(explosion)

		# Damage the entity
		if body.name == "Player" and body.has_signal("hit"):
			body.emit_signal("hit")
		elif body.is_in_group("enemies"):
			body.queue_free()

		queue_free()