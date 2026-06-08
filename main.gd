extends Node2D

var enemy_scene = preload("res://enemy.tscn")
var boost_scene = preload("res://boost.tscn")
var police_scene = preload("res://police.tscn")
var obstacle_scene = preload("res://obstacle.tscn")

var score = 0
var game_over = false

var lines = []
var line_spacing = 100.0
var line_height = 50.0

func _ready():
	$EnemySpawnTimer.start()
	$BoostSpawnTimer.start()
	$ObstacleSpawnTimer.start()
	$ScoreTimer.start()
	$UI/GameOverLabel.hide()
	$UI/ScoreLabel.text = "Score: " + str(score)

	# Generate center dashed lines
	for i in range(10):
		var line = ColorRect.new()
		line.color = Color(1, 1, 0, 1) # Yellow dashed line
		line.size = Vector2(5, line_height)
		line.position = Vector2(197.5, i * line_spacing - line_height)
		$CenterLines.add_child(line)
		lines.append(line)

func _process(delta):
	if game_over:
		if Input.is_action_just_pressed("boost"):
			get_tree().reload_current_scene()
		return

	# Move dashed lines based on player speed
	var player_speed = $Player.speed if $Player else 300.0
	for line in lines:
		line.position.y += player_speed * delta
		if line.position.y > 800:
			line.position.y -= (10 * line_spacing)

func _on_enemy_spawn_timer_timeout():
	if game_over: return
	var enemy = enemy_scene.instantiate()

	# Decide lane: 0 = Left (Oncoming), 1 = Right (Same direction)
	var lane = randi() % 2

	if lane == 0:
		enemy.position = Vector2(randf_range(70, 180), -80)
		enemy.speed = randf_range(150, 300) # Coming towards player (relative to road)
		enemy.direction = 1 # Downward
		# Facing down natively, so no rotation needed
	else:
		enemy.position = Vector2(randf_range(220, 330), -80)
		enemy.speed = randf_range(150, 250) # Slower than player, driving in same direction
		enemy.direction = 1
		enemy.rotation = PI # Flip car to face upwards (same direction as player)

	# Store the main node so enemies can calculate relative speed
	enemy.main_node = self
	add_child(enemy)

func _on_boost_spawn_timer_timeout():
	if game_over: return
	var boost = boost_scene.instantiate()
	var lane = randi() % 2
	if lane == 0:
		boost.position = Vector2(randf_range(70, 180), -50)
	else:
		boost.position = Vector2(randf_range(220, 330), -50)

	boost.main_node = self
	add_child(boost)

func _on_obstacle_spawn_timer_timeout():
	if game_over: return
	var obs = obstacle_scene.instantiate()
	var side = randi() % 2
	if side == 0:
		obs.position = Vector2(randf_range(10, 40), -50) # Left grass
	else:
		obs.position = Vector2(randf_range(360, 390), -50) # Right grass

	obs.main_node = self
	add_child(obs)

func _on_score_timer_timeout():
	if game_over: return
	score += 10
	if Input.is_action_pressed("boost"):
		score += 10 # Double score while boosting
	$UI/ScoreLabel.text = "Score: " + str(score)

func _on_player_hit():
	if game_over: return
	game_over = true
	$Player.hide()
	$Player.set_physics_process(false)
	$UI/GameOverLabel.show()
	$EnemySpawnTimer.stop()
	$BoostSpawnTimer.stop()
	$ObstacleSpawnTimer.stop()
	$ScoreTimer.stop()

	# Spawn explosion on player
	var explosion_scene = load("res://explosion.tscn")
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.position = $Player.position
		add_child(explosion)

func _on_player_boost_changed(amount):
	$UI/BoostLabel.text = "Boost: " + str(int(amount))

func _on_player_wrong_lane_boost_collected():
	if game_over: return

	# 50% chance to spawn police when a boost is taken from the wrong lane
	if randi() % 2 == 0:
		var police = police_scene.instantiate()
		# Spawn at the bottom of the screen in the left lane
		police.position = Vector2(randf_range(70, 180), 900)
		police.main_node = self
		add_child(police)