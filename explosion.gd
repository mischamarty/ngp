extends Node2D

func _ready():
	$CPUParticles2D.emitting = true
	$AudioStreamPlayer.stream = preload("res://explosion.wav")
	$AudioStreamPlayer.play()

func _on_timer_timeout():
	queue_free()