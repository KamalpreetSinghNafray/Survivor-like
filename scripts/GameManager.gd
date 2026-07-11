extends Node

var gameplay_paused := false

var xp_multiplier := 1.0

var enemy_speed_multiplier := 1.0
var enemy_health_multiplier := 1.0
var enemy_damage_multiplier := 1.0

var spawn_rate_multiplier := 1.0

var active_contracts: Array = []

var contract_interval := 20.0
var time_until_contract := contract_interval


func _process(delta):

	if gameplay_paused:
		return

	time_until_contract -= delta


func should_show_contract() -> bool:

	if time_until_contract <= 0:

		time_until_contract = contract_interval

		return true

	return false


func apply_contract(contract: ContractData):

	active_contracts.append(contract)
	print(contract)
	print(contract.get_script())
	print(contract.get_property_list())


	match contract.effect:

		"enemy_speed":
			enemy_speed_multiplier *= contract.value

		"enemy_health":
			enemy_health_multiplier *= contract.value

		"spawn_rate":
			spawn_rate_multiplier *= contract.value

		"glass_cannon":
			pass

		"no_heal":
			pass

	print("Contract:", contract.title)
