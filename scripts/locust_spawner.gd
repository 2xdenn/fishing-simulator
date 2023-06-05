extends Node3D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var desertLocust = preload("res://interactable/desert_locust.tscn")
@onready var target_grass = $TargetGrass
var locust: RigidBody3D
var locustActive: bool = false
var spawnReady: bool = true

func _on_spawn_grass_area_body_entered(body):
	$GrassRustle.play()
	if body.is_in_group("Player") && spawnReady:
		locust = desertLocust.instantiate()
		add_child(locust)
		locust.look_at(target_grass.global_position, Vector3.UP, true)
		locustActive = true
		spawnReady = false
		spawn_timer.wait_time = 5
		spawn_timer.start()

func _on_target_grass_area_body_entered(body):
	if body.is_in_group("Bug") && locustActive:
		$TargetGrass/GrassRustle3D.play()
		locust.queue_free()
		locustActive = false

func _on_spawn_timer_timeout():
	spawnReady = true
