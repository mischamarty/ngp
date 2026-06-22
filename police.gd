extends CharacterBody3D

var speed = 30.0 # Faster than player
var main_node = null
var is_siren_red = true
var bounce_velocity = Vector3.ZERO

func apply_bounce(b_vel):
	bounce_velocity = b_vel

func _ready():
	var siren_audio = AudioStreamPlayer3D.new()
	siren_audio.name = "SirenSound"
	siren_audio.stream = preload("res://siren.wav")
	siren_audio.volume_db = -10.0
	add_child(siren_audio)

func _physics_process(delta):
	var player_speed = 0.0
	if main_node and main_node.has_node("Player") and not main_node.game_over:
		player_speed = main_node.get_node("Player").speed

	# Police spawned behind player (Z = 10)
	# Moves forward (negative Z) relative to player
	var forward_movement = (player_speed - speed)

	bounce_velocity = bounce_velocity.lerp(Vector3.ZERO, 5 * delta)
	velocity = Vector3(0, 0, forward_movement) + bounce_velocity
	move_and_slide()

	# Despawn if it gets far ahead (Z < -50)
	if position.z < -50 or position.x < -15 or position.x > 15:
		queue_free()

func _on_siren_timer_timeout():
	if has_node("SirenSound") and not $SirenSound.playing:
		$SirenSound.play()

	is_siren_red = !is_siren_red
	if is_siren_red:
		$Visuals/SirenLeft.light_energy = 5.0
		$Visuals/SirenRight.light_energy = 1.0
	else:
		$Visuals/SirenLeft.light_energy = 1.0
		$Visuals/SirenRight.light_energy = 5.0