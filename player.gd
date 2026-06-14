extends CharacterBody3D

const BASE_SPEED = 20.0
const BOOST_SPEED_MULTIPLIER = 2.0
const MAX_BOOST = 100.0
const MAX_HEALTH = 3

var speed = BASE_SPEED
var boost_level = MAX_BOOST
var health = MAX_HEALTH

signal hit
signal health_changed(amount)
signal boost_changed(amount)
signal wrong_lane_boost_collected
signal game_over_signal

func _ready():
	$BounceSound.stream = preload("res://bounce.wav")
	emit_signal("health_changed", health)

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1

	# In 3D forward perspective, Z is forward/back. We just move laterally (X)
	# The road scrolling makes it look like we move forward

	var is_boosting = Input.is_action_pressed("boost") and boost_level > 0

	if is_boosting:
		speed = BASE_SPEED * BOOST_SPEED_MULTIPLIER
		boost_level -= 20.0 * delta
	else:
		speed = BASE_SPEED
		if boost_level < MAX_BOOST:
			boost_level = min(boost_level + 5.0 * delta, MAX_BOOST)

	emit_signal("boost_changed", boost_level)

	var target_velocity = Vector3(input_vector.x * 10.0, 0, 0)

	if target_velocity != Vector3.ZERO:
		velocity = velocity.lerp(target_velocity, 10 * delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, 5 * delta)

	move_and_slide()

	# Handle Bouncing with enemies
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("enemies"):
			var bounce_dir = collision.get_normal()
			bounce_dir.y = 0 # Keep bounce strictly horizontal
			velocity = bounce_dir * 15.0
			if collider.has_method("apply_bounce"):
				collider.apply_bounce(-bounce_dir * 15.0)
			if not $BounceSound.playing:
				$BounceSound.play()

	# Clamp position to the road/shoulders.
	# Road is from x = -5 to x = 5. Shoulders extend to -8 and 8.
	position.x = clamp(position.x, -7.5, 7.5)
	position.z = 0 # Lock Z position
	position.y = 0

func add_boost(amount):
	boost_level = min(boost_level + amount, MAX_BOOST)

func take_damage():
	health -= 1
	emit_signal("health_changed", health)
	emit_signal("hit")

	if health <= 0:
		emit_signal("game_over_signal")

func heal(amount):
	health = min(health + amount, MAX_HEALTH)
	emit_signal("health_changed", health)