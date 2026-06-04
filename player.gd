extends Area2D

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

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized()

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

	position += velocity * speed * delta
	position.x = clamp(position.x, 25, screen_size.x - 25)
	position.y = clamp(position.y, 50, screen_size.y - 50)

func add_boost(amount):
	boost_level = min(boost_level + amount, MAX_BOOST)

func _on_body_entered(body):
	emit_signal("hit")

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		emit_signal("hit")
	elif area.is_in_group("boosts"):
		add_boost(30)
		area.queue_free()