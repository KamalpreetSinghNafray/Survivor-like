extends Node

var gameplay_paused := false

# Cached player reference
var player: CharacterBody2D

# Enemy counters
var enemy_count := 0
var big_enemy_count := 0

# Player modifiers
var xp_multiplier := 1.0

# Curse Trackers
var is_glass_cannon := false

# Enemy modifiers
var enemy_speed_multiplier := 1.0
var enemy_health_multiplier := 1.0
var enemy_damage_multiplier := 1.0

# Spawner modifiers
var spawn_rate_multiplier := 1.0

# Contracts
var active_contracts: Array = []

# Run timer
var run_time := 0.0

# Contract timer
var contract_interval := 60.0
var time_until_contract := contract_interval


func _process(delta):
	if gameplay_paused:
		return

	run_time += delta
	time_until_contract -= delta


func should_show_contract() -> bool:
	if time_until_contract <= 0.0:
		time_until_contract = contract_interval
		return true

	return false


func apply_contract(contract: ContractData):
	active_contracts.append(contract)

	match contract.effect:
		"enemy_speed":
			enemy_speed_multiplier *= contract.value
		"enemy_health":
			enemy_health_multiplier *= contract.value
		"enemy_damage":
			enemy_damage_multiplier *= contract.value
		"spawn_rate":
			spawn_rate_multiplier *= contract.value
		"glass_cannon":
			is_glass_cannon = true
			if is_instance_valid(player):
				player.max_hp = 1
				player.hp = 1
				player.hud.update_health(player.hp, player.max_hp)
				player.bullet_damage *= 4
		"no_heal":
			pass

	print("Contract:", contract.title)


func reset_run():
	# 1. State
	gameplay_paused = false
	player = null
	
	# 2. Counters
	enemy_count = 0
	big_enemy_count = 0
	
	# 3. Player Modifiers
	xp_multiplier = 1.0
	is_glass_cannon = false
	
	# 4. Enemy Modifiers
	enemy_speed_multiplier = 1.0
	enemy_health_multiplier = 1.0
	enemy_damage_multiplier = 1.0
	
	# 5. Spawner Modifiers
	spawn_rate_multiplier = 1.0
	
	# 6. Data & Timers
	active_contracts.clear()
	run_time = 0.0
	contract_interval = 60.0 # Hard-reset just in case it was altered
	time_until_contract = contract_interval
