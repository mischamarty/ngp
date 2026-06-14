extends Node3D

func _ready():
	$CPUParticles3D.emitting = true
	$AudioStreamPlayer3D.stream = preload("res://explosion.wav")
	$AudioStreamPlayer3D.play()

func _on_timer_timeout():
	queue_free()