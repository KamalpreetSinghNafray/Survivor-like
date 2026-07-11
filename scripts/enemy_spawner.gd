extends Node2D

@export var enemy_scene: PackedScene
@export var player: Node2D

var base_spawn_time := 1.5
var current_spawn_time := 1.5
var min_spawn_time := 0.2
var difficulty_scaling := 0.95

var spawn_timer: Timer
var difficulty_timer: Timer


func _ready():
	randomize()

	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	difficulty_timer = Timer.new()
	difficulty_timer.wait_time = 10.0
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)
	add_child(difficulty_timer)

	_update_spawn_timer()

	spawn_timer.start()
	difficulty_timer.start()


func _physics_process(_delta):

	if Game_Manager.gameplay_paused:

		if !spawn_timer.paused:
			spawn_timer.paused = true

		if !difficulty_timer.paused:
			difficulty_timer.paused = true

	else:

		spawn_timer.paused = false
		difficulty_timer.paused = false


func _update_spawn_timer():

	spawn_timer.wait_time = current_spawn_time / Game_Manager.spawn_rate_multiplier


func _on_spawn_timer_timeout():

	if !is_instance_valid(player):
		return

	if player.dead:
		return

	if enemy_scene == null:
		return

	var enemy = enemy_scene.instantiate()

	var viewport_size = get_viewport().get_visible_rect().size
	var spawn_radius = max(viewport_size.x, viewport_size.y) / 1.5

	var angle = randf() * TAU

	var offset = Vector2(
		cos(angle),
		sin(angle)
	) * spawn_radius

	enemy.global_position = player.global_position + offset

	get_tree().current_scene.add_child(enemy)


func _on_difficulty_timer_timeout():

	current_spawn_time *= difficulty_scaling

	current_spawn_time = max(current_spawn_time, min_spawn_time)

	_update_spawn_timer()
