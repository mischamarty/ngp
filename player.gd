extends CharacterBody2D

const BASE_SPEED = 300.0
const BOOST_SPEED_MULTIPLIER = 2.0
const MAX_BOOST = 100.0
const BOOST_DEPLETION_RATE = 20.0
const BOOST_RECOVERY_RATE = 5.0

var speed = BASE_SPEED
var boost_level = MAX_BOOST
var screen_size: Vector2

signal hit
signal boost_changed(amount)
signal wrong_lane_boost_collected

func _ready():
	screen_size = get_viewport_rect().size

	# Add AudioStreamPlayer for bounce
	var audio = AudioStreamPlayer.new()
	audio.name = "BounceSound"
	audio.stream = preload("res://bounce.wav")
	add_child(audio)

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

	var is_boosting = Input.is_action_pressed("boost") and boost_level > 0

	if is_boosting:
		speed = BASE_SPEED * BOOST_SPEED_MULTIPLIER
		boost_level -= BOOST_DEPLETION_RATE * delta
	else:
		speed = BASE_SPEED
		if boost_level < MAX_BOOST:
			boost_level += BOOST_RECOVERY_RATE * delta
			boost_level = min(boost_level, MAX_BOOST)

	emit_signal("boost_changed", boost_level)

	# Apply normal movement target, but allow velocity to carry bounce momentum
	# If input is provided, smoothly transition back to input control
	if input_vector != Vector2.ZERO:
		velocity = velocity.lerp(input_vector * speed, 10 * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, 5 * delta)

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("enemies"):
			# Bounce logic
			var bounce_dir = collision.get_normal()
			velocity = bounce_dir * 500 # bounce force
			if collider.has_method("apply_bounce"):
				collider.apply_bounce(-bounce_dir * 500)

			if not $BounceSound.playing:
				$BounceSound.play()

	# clamp to grass/road area. Grass is 0-50, 350-400. Road is 50-350.
	# Allow player to be pushed onto grass, but bounded by screen (25 to 375 with margin)
	position.x = clamp(position.x, 25, 375)
	position.y = clamp(position.y, 50, screen_size.y - 50)

func add_boost(amount):
	boost_level = min(boost_level + amount, MAX_BOOST)

# Area signals were removed, boosts are now handled by boost.gd's body_entered