extends Node2D

@export_group("Enemy Scenes")
@export var enemy_scene: PackedScene
@export var big_enemy_scene: PackedScene
@export var player: Node2D

@export_group("Spawn Limits")
@export var max_enemies: int = 100
@export var max_big_enemies: int = 10

@export_group("Elite Spawn")
@export var elite_start_time: float = 60.0

@export_range(0.0, 1.0, 0.01)
var elite_start_chance: float = 0.10

@export_range(0.0, 1.0, 0.01)
var elite_max_chance: float = 0.33

@export var elite_ramp_time: float = 240.0

@export_group("Difficulty")
@export var base_spawn_time: float = 1.5
@export var min_spawn_time: float = 0.2
@export var difficulty_scaling: float = 0.95

var current_spawn_time: float

var spawn_timer: Timer
var difficulty_timer: Timer


func _ready():

	randomize()

	current_spawn_time = base_spawn_time

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

	spawn_timer.paused = Game_Manager.gameplay_paused
	difficulty_timer.paused = Game_Manager.gameplay_paused


func _update_spawn_timer():

	spawn_timer.wait_time = current_spawn_time / Game_Manager.spawn_rate_multiplier


func _on_spawn_timer_timeout():

	if !is_instance_valid(player):
		return

	if player.dead:
		return

	# Total enemy limit
	if Game_Manager.enemy_count >= max_enemies:
		return

	var scene_to_spawn: PackedScene = enemy_scene

	# Elite spawn chance
	if Game_Manager.run_time >= elite_start_time:

		if randf() <= get_big_enemy_chance():

			if Game_Manager.big_enemy_count < max_big_enemies:
				scene_to_spawn = big_enemy_scene

	if scene_to_spawn == null:
		return

	var enemy: CharacterBody2D = scene_to_spawn.instantiate()

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	var spawn_radius: float = max(viewport_size.x, viewport_size.y) / 1.5

	var angle: float = randf() * TAU

	var offset: Vector2 = Vector2(
		cos(angle),
		sin(angle)
	) * spawn_radius

	enemy.global_position = player.global_position + offset

	get_tree().current_scene.add_child(enemy)


func get_big_enemy_chance() -> float:

	var elapsed := clampf(
		Game_Manager.run_time - elite_start_time,
		0.0,
		elite_ramp_time
	)

	return lerpf(
		elite_start_chance,
		elite_max_chance,
		elapsed / elite_ramp_time
	)


func _on_difficulty_timer_timeout():

	current_spawn_time *= difficulty_scaling
	current_spawn_time = max(current_spawn_time, min_spawn_time)

	_update_spawn_timer()
