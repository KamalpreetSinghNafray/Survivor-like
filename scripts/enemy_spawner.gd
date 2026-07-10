extends Node2D

@export var enemy_scene: PackedScene
@export var player: Node2D

# Spawning variables
var current_spawn_time: float = 1.5
var min_spawn_time: float = 0.2
var difficulty_scaling: float = 0.95 # Multiplies spawn time every 10 seconds

var spawn_timer: Timer
var difficulty_timer: Timer

func _ready() -> void:
	randomize()
	
	# Setup the timer that spawns enemies
	spawn_timer = Timer.new()
	spawn_timer.wait_time = current_spawn_time
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()
	
	# Setup the timer that increases difficulty over time
	difficulty_timer = Timer.new()
	difficulty_timer.wait_time = 10.0 # Difficulty increases every 10 seconds
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)
	add_child(difficulty_timer)
	difficulty_timer.start()

func _on_spawn_timer_timeout() -> void:
	# Don't spawn if the player is missing or dead, or if no scene is assigned
	if not is_instance_valid(player) or not enemy_scene:
		return
	if player.get("dead") == true:
		return
		
	var enemy = enemy_scene.instantiate()
	
	# Calculate a spawn position just outside the camera's view
	# Using the viewport's longest side ensures the radius is always off-screen
	var viewport_size = get_viewport().get_visible_rect().size
	var spawn_radius = max(viewport_size.x, viewport_size.y) / 1.5 
	
	# Pick a random angle (TAU is 2 * PI, representing a full circle in radians)
	var random_angle = randf() * TAU
	var spawn_offset = Vector2(cos(random_angle), sin(random_angle)) * spawn_radius
	
	enemy.global_position = player.global_position + spawn_offset
	
	# Add enemy to the current scene tree, NOT as a child of the player
	# This ensures enemies don't move when the spawner or player moves
	get_tree().current_scene.add_child(enemy)

func _on_difficulty_timer_timeout() -> void:
	# Gradually decrease the time between spawns
	current_spawn_time *= difficulty_scaling
	
	if current_spawn_time < min_spawn_time:
		current_spawn_time = min_spawn_time
		
	spawn_timer.wait_time = current_spawn_time
