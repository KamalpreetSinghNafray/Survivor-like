extends CharacterBody2D

@export var move_speed := 120.0
@export var acceleration := 800.0

@export var max_hp := 3
@export var xp_gem_scene: PackedScene
@export var xp_amount: int = 1

@export var attack_range := 35.0
@export var attack_damage := 1
@export var attack_windup := 0.15
@export var attack_cooldown := 0.8

@export var is_big_enemy := false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var hp: int
var attack_range_sq: float

var dead := false
var hurt := false
var attacking := false
var can_attack := true


func _ready():

	Game_Manager.enemy_count += 1

	if is_big_enemy:
		Game_Manager.big_enemy_count += 1

	add_to_group("Enemy")

	move_speed *= Game_Manager.enemy_speed_multiplier
	max_hp = int(round(max_hp * Game_Manager.enemy_health_multiplier))
	attack_damage = int(round(attack_damage * Game_Manager.enemy_damage_multiplier))

	hp = max_hp
	attack_range_sq = attack_range * attack_range

	animated_sprite.play("walk")


func _physics_process(delta):

	if Game_Manager.gameplay_paused:
		return

	if dead or hurt:
		return

	var player: CharacterBody2D = Game_Manager.player

	if player == null or !is_instance_valid(player):
		return

	var dir: Vector2 = player.global_position - global_position
	var distance_sq: float = dir.length_squared()

	if dir.x != 0.0:
		animated_sprite.flip_h = dir.x < 0

	if distance_sq <= attack_range_sq:

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

	await animated_sprite.animation_finished

	if dead:
		return

	attacking = false

	animated_sprite.play("walk")

	await get_tree().create_timer(attack_cooldown).timeout

	if !dead:
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

	Game_Manager.enemy_count -= 1

	if is_big_enemy:
		Game_Manager.big_enemy_count -= 1

	velocity = Vector2.ZERO

	animated_sprite.play("death")

	await animated_sprite.animation_finished

	if xp_gem_scene:

		var xp_gem = xp_gem_scene.instantiate()
		xp_gem.xp_amount = xp_amount

		get_tree().current_scene.add_child(xp_gem)

		xp_gem.global_position = global_position + Vector2(
			randf_range(-8.0, 8.0),
			randf_range(-8.0, 8.0)
		)

	queue_free()


func _on_animated_sprite_2d_frame_changed():
	# NEW: Safety check in case the sprite fires a signal before the script is fully loaded
	if animated_sprite == null:
		return

	if dead:
		return

	if animated_sprite.animation != "attack":
		return

	if animated_sprite.frame != 3:
		return

	var player: CharacterBody2D = Game_Manager.player

	if player == null or !is_instance_valid(player):
		return

	if global_position.distance_squared_to(player.global_position) <= attack_range_sq:
		player.take_damage(attack_damage)
