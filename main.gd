extends Node2D

var enemy_scene = preload("res://enemy.tscn")
var boost_scene = preload("res://boost.tscn")

var score = 0
var game_over = false

func _ready():
	$EnemySpawnTimer.start()
	$BoostSpawnTimer.start()
	$ScoreTimer.start()
	$UI/GameOverLabel.hide()
	$UI/ScoreLabel.text = "Score: " + str(score)

func _process(delta):
	if game_over:
		if Input.is_action_just_pressed("boost"):
			get_tree().reload_current_scene()
		return

	# Simple scrolling road effect
	var offset = fmod(Time.get_ticks_msec() / 10.0, 100.0)
	$RoadLine.position.y = offset - 100

func _on_enemy_spawn_timer_timeout():
	if game_over: return
	var enemy = enemy_scene.instantiate()
	var x_pos = randf_range(50, 350)
	enemy.position = Vector2(x_pos, -50)
	enemy.speed = randf_range(150, 300)
	add_child(enemy)

func _on_boost_spawn_timer_timeout():
	if game_over: return
	var boost = boost_scene.instantiate()
	var x_pos = randf_range(50, 350)
	boost.position = Vector2(x_pos, -50)
	add_child(boost)

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
	$Player.set_deferred("monitoring", false)
	$UI/GameOverLabel.show()
	$EnemySpawnTimer.stop()
	$BoostSpawnTimer.stop()
	$ScoreTimer.stop()

func _on_player_boost_changed(amount):
	$UI/BoostLabel.text = "Boost: " + str(int(amount))