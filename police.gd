extends CharacterBody2D

var speed = 400.0 # Much faster than the player
var main_node = null
var is_siren_red = true
var bounce_velocity = Vector2.ZERO

func apply_bounce(b_vel):
	bounce_velocity = b_vel

func _ready():
	var siren_audio = AudioStreamPlayer.new()
	siren_audio.name = "SirenSound"
	siren_audio.stream = preload("res://siren.wav")
	siren_audio.volume_db = -10.0
	add_child(siren_audio)

func _physics_process(delta):
	var player_speed = 300.0
	if main_node and main_node.has_node("Player") and not main_node.game_over:
		player_speed = main_node.get_node("Player").speed

	var forward_movement = (player_speed - speed)

	bounce_velocity = bounce_velocity.lerp(Vector2.ZERO, 5 * delta)
	velocity = Vector2(0, forward_movement) + bounce_velocity
	move_and_slide()

	if position.y < -150 or position.y > 1050 or position.x < -100 or position.x > 500: # Destroy when it gets far ahead or knocked off screen
		queue_free()

func _on_siren_timer_timeout():
	if has_node("SirenSound") and not $SirenSound.playing:
		$SirenSound.play()

	is_siren_red = !is_siren_red
	if is_siren_red:
		$Visuals/SirenLeft.color = Color(1, 0, 0, 1) # Red
		$Visuals/SirenRight.color = Color(0, 0, 1, 0.3) # Dim blue
	else:
		$Visuals/SirenLeft.color = Color(1, 0, 0, 0.3) # Dim red
		$Visuals/SirenRight.color = Color(0, 0, 1, 1) # Blue