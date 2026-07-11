extends CharacterBody2D

@export var move_speed := 120.0
@export var acceleration := 800.0

@export var max_hp := 3
@export var xp_gem_scene: PackedScene

@export var attack_range := 35.0
@export var attack_damage := 1
@export var attack_windup := 0.15
@export var attack_cooldown := 0.8

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D

var hp: int

var dead := false
var hurt := false
var attacking := false
var can_attack := true


func _ready():

	add_to_group("Enemy")

	# Apply current run modifiers
	move_speed *= Game_Manager.enemy_speed_multiplier
	max_hp = int(round(max_hp * Game_Manager.enemy_health_multiplier))
	attack_damage = int(round(attack_damage * Game_Manager.enemy_damage_multiplier))

	hp = max_hp

	animated_sprite.play("walk")


func _physics_process(delta):

	if Game_Manager.gameplay_paused:
		return

	if dead or hurt:
		return

	if player == null:
		player = get_tree().get_first_node_in_group("Player")
		if player == null:
			return

	var dir = player.global_position - global_position
	var distance = dir.length()

	if dir.x != 0:
		animated_sprite.flip_h = dir.x < 0

	if distance <= attack_range:

		velocity = Vector2.ZERO
		move_and_slide()

		if can_attack and !attacking:
			attack()

		return

	if !attacking:

		velocity = velocity.move_toward(
			dir.normalized() * move_speed,
			acceleration * delta
		)

		move_and_slide()

		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")


func attack():

	attacking = true
	can_attack = false

	velocity = Vector2.ZERO

	animated_sprite.play("attack")

	await get_tree().create_timer(attack_windup).timeout

	if dead or hurt:
		return

	if player and global_position.distance_to(player.global_position) <= attack_range:
		player.take_damage(attack_damage)

	await animated_sprite.animation_finished

	if dead:
		return

	attacking = false

	animated_sprite.play("walk")

	await get_tree().create_timer(attack_cooldown).timeout

	can_attack = true


func take_damage(amount):

	if dead:
		return

	hp -= amount

	if hp <= 0:
		die()
		return

	hurt = true

	velocity = Vector2.ZERO

	animated_sprite.play("hurt")

	await animated_sprite.animation_finished

	if dead:
		return

	hurt = false

	if !attacking:
		animated_sprite.play("walk")


func die():

	if dead:
		return

	dead = true

	velocity = Vector2.ZERO

	animated_sprite.play("death")

	await animated_sprite.animation_finished

	if xp_gem_scene:

		var xp_gem = xp_gem_scene.instantiate()

		get_tree().current_scene.add_child(xp_gem)

		xp_gem.global_position = global_position + Vector2(
			randf_range(-8, 8),
			randf_range(-8, 8)
		)

	queue_free()
