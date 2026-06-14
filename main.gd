extends Node3D

var enemy_scene = preload("res://enemy.tscn")
var boost_scene = preload("res://boost.tscn")
var police_scene = preload("res://police.tscn")
var bomb_scene = preload("res://bomb.tscn")
var health_scene = preload("res://health.tscn")

var score = 0
var game_over = false

var lines = []
var line_spacing = 5.0
var line_length = 2.0

func _ready():
	$EnemySpawnTimer.start()
	$BoostSpawnTimer.start()
	$BombSpawnTimer.start()
	$HealthSpawnTimer.start()
	$ScoreTimer.start()
	$UI/GameOverLabel.hide()
	$UI/ScoreLabel.text = "Score: " + str(score)

	# Create materials for road/grass that were referenced in scene but not saved inline
	var mat_grass = StandardMaterial3D.new()
	mat_grass.albedo_color = Color(0.2, 0.6, 0.2)
	$RoadEnvironment/Grass.material = mat_grass

	var mat_road = StandardMaterial3D.new()
	mat_road.albedo_color = Color(0.3, 0.3, 0.3)
	$RoadEnvironment/Road.material = mat_road

	var mat_line = StandardMaterial3D.new()
	mat_line.albedo_color = Color(1, 1, 0)

	for i in range(20):
		var line = CSGBox3D.new()
		line.size = Vector3(0.2, 0.1, line_length)
		line.material = mat_line
		line.position = Vector3(0, 0.06, -i * line_spacing)
		$RoadEnvironment/CenterLines.add_child(line)
		lines.append(line)

func _process(delta):
	if game_over:
		if Input.is_action_just_pressed("boost"):
			get_tree().reload_current_scene()
		return

	var player_speed = $Player.speed if $Player else 20.0
	for line in lines:
		line.position.z += player_speed * delta
		if line.position.z > 5:
			line.position.z -= (20 * line_spacing)

func _on_enemy_spawn_timer_timeout():
	if game_over: return
	var enemy = enemy_scene.instantiate()
	var lane = randi() % 2

	if lane == 0: # Left lane (oncoming)
		enemy.position = Vector3(randf_range(-4, -1), 0, -50)
		enemy.speed = randf_range(15, 30)
		# Face towards player
	else: # Right lane (same direction)
		enemy.position = Vector3(randf_range(1, 4), 0, -50)
		enemy.speed = randf_range(10, 18)
		enemy.rotation.y = PI # Face away

	enemy.main_node = self
	add_child(enemy)

func _on_boost_spawn_timer_timeout():
	if game_over: return
	var boost = boost_scene.instantiate()
	var lane = randi() % 2
	if lane == 0:
		boost.position = Vector3(randf_range(-4, -1), 0, -50)
	else:
		boost.position = Vector3(randf_range(1, 4), 0, -50)

	boost.main_node = self
	add_child(boost)

func _on_bomb_spawn_timer_timeout():
	if game_over: return
	var obs = bomb_scene.instantiate()
	# Bombs can spawn on the road or shoulders
	obs.position = Vector3(randf_range(-6, 6), 0, -50)
	obs.main_node = self
	add_child(obs)

func _on_health_spawn_timer_timeout():
	if game_over: return
	var hp = health_scene.instantiate()
	hp.position = Vector3(randf_range(-4, 4), 0, -50)
	hp.main_node = self
	add_child(hp)

func _on_score_timer_timeout():
	if game_over: return
	score += 10
	if Input.is_action_pressed("boost"):
		score += 10
	$UI/ScoreLabel.text = "Score: " + str(score)

func _on_player_health_changed(amount):
	$UI/HealthLabel.text = "Health: " + str(int(amount)) + "/3"

func _on_player_game_over():
	if game_over: return
	game_over = true
	$Player.hide()
	$Player.set_physics_process(false)
	$UI/GameOverLabel.show()
	$EnemySpawnTimer.stop()
	$BoostSpawnTimer.stop()
	$BombSpawnTimer.stop()
	$HealthSpawnTimer.stop()
	$ScoreTimer.stop()

	var explosion_scene = load("res://explosion.tscn")
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.position = $Player.position
		add_child(explosion)

func _on_player_boost_changed(amount):
	$UI/BoostLabel.text = "Boost: " + str(int(amount))

func _on_player_wrong_lane_boost_collected():
	if game_over: return

	if randi() % 2 == 0:
		var police = police_scene.instantiate()
		# Spawn behind the player in the oncoming lane
		police.position = Vector3(randf_range(-4, -1), 0, 10)
		police.main_node = self
		add_child(police)