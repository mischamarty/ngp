extends CharacterBody2D

var speed = 200.0
var direction = 1
var main_node = null
var bounce_velocity = Vector2.ZERO

func apply_bounce(b_vel):
	bounce_velocity = b_vel

func _physics_process(delta):
	var player_speed = 300.0
	var forward_movement = 0.0
	if main_node and main_node.has_node("Player") and main_node.game_over == false:
		player_speed = main_node.get_node("Player").speed

	if rotation == 0:
		# Oncoming traffic
		forward_movement = (speed + player_speed)
	else:
		# Same direction traffic
		forward_movement = (player_speed - speed)

	# Recover from bounce
	bounce_velocity = bounce_velocity.lerp(Vector2.ZERO, 5 * delta)

	velocity = Vector2(0, forward_movement) + bounce_velocity
	move_and_slide()

	# Despawn if off-screen (bottom or top)
	if position.y > 1050 or position.y < -300 or position.x < -100 or position.x > 500:
		queue_free()