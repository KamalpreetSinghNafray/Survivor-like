extends CharacterBody2D

@export var move_speed := 120.0
@export var hp := 3
@export var attack_range := 35.0
@export var attack_damage := 1
@export var attack_cooldown := 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D
var dead := false
var hurt := false
var can_attack := true
var attacking := false


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	add_to_group("Enemy")
	animated_sprite.play("walk")


func _physics_process(_delta):
	if dead or hurt or player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	# If attacking, stay still until attack finishes
	if attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Attack if close enough
	if distance <= attack_range:
		attack()
		return

	# Chase player
	var dir = (player.global_position - global_position).normalized()

	velocity = dir * move_speed
	move_and_slide()

	if dir.x != 0:
		animated_sprite.flip_h = dir.x < 0

	if animated_sprite.animation != "walk":
		animated_sprite.play("walk")


func take_damage(amount):
	if dead or hurt:
		return

	hp -= amount

	if hp <= 0:
		die()
	else:
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
	dead = true
	velocity = Vector2.ZERO

	animated_sprite.play("death")

	await animated_sprite.animation_finished

	queue_free()


func attack():
	if !can_attack or hurt or dead or attacking:
		return

	attacking = true
	can_attack = false
	velocity = Vector2.ZERO

	animated_sprite.play("attack")

	# Damage timing
	await get_tree().create_timer(0.15).timeout

	if player and global_position.distance_to(player.global_position) <= attack_range:
		player.take_damage(attack_damage)

	await animated_sprite.animation_finished

	attacking = false

	if !dead and !hurt:
		animated_sprite.play("walk")

	await get_tree().create_timer(attack_cooldown).timeout

	can_attack = true
