extends CharacterBody3D

var speed = 10.0
var main_node = null
var bounce_velocity = Vector3.ZERO

func apply_bounce(b_vel):
	bounce_velocity = b_vel

func _physics_process(delta):
	var player_speed = 20.0
	var forward_movement = 0.0

	if main_node and main_node.has_node("Player") and main_node.game_over == false:
		player_speed = main_node.get_node("Player").speed

	# In 3D, negative Z is "forward" into the distance.
	# Player is at Z=0.
	# Enemy spawned at Z = -40 (far away).
	# They need to move towards Z=0 (positive Z movement).

	if rotation.y == 0:
		# Oncoming traffic (facing us)
		forward_movement = (speed + player_speed)
	else:
		# Same direction traffic (facing away)
		forward_movement = (player_speed - speed)

	bounce_velocity = bounce_velocity.lerp(Vector3.ZERO, 5 * delta)

	velocity = Vector3(0, 0, forward_movement) + bounce_velocity
	move_and_slide()

	# Despawn if it passes the camera (Z > 5) or goes too far to the sides
	if position.z > 5 or position.x < -15 or position.x > 15:
		queue_free()