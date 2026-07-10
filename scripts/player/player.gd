extends CharacterBody2D

@export var move_speed: float = 250.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.1
@export var max_ammo: int = 30
@export var reload_time: float = 3.0

@export var max_camera_offset := 120.0
@export var camera_smoothness := 12.0

@export var max_hp := 10

@export var shake_strength := 12.0
@export var shake_duration := 0.15

@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var muzzle: Marker2D = $WeaponPivot/Muzzle
@onready var camera: Camera2D = $Camera2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var hp: int
var current_ammo: int
var can_shoot := true
var is_reloading := false
var dead := false

var shake_time := 0.0
var current_shake := 0.0


func _ready():
	hp = max_hp
	current_ammo = max_ammo


func _physics_process(delta):
	if dead:
		return

	move()
	aim()
	update_camera(delta)
	handle_auto_shoot()


func move():
	var input := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = input * move_speed
	move_and_slide()

	if input.x != 0:
		animated_sprite.flip_h = input.x < 0

	if input.length() > 0:
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")


func aim():
	var mouse_pos = get_global_mouse_position()

	weapon_pivot.look_at(mouse_pos)

	var angle = (mouse_pos - global_position).angle()

	if abs(angle) > PI / 2:
		weapon_pivot.scale.y = -1
	else:
		weapon_pivot.scale.y = 1


func _unhandled_input(event):
	if dead:
		if event.is_action_pressed("shoot"):
			get_tree().paused = false
			get_tree().reload_current_scene()
		return

	# Manual reload triggered by a dedicated input (e.g., 'R' key)
	if event.is_action_pressed("reload"):
		if current_ammo < max_ammo and not is_reloading:
			start_reload()


func handle_auto_shoot():
	# Continuously attempt to shoot while holding the button
	if Input.is_action_pressed("shoot"):
		try_shoot()


func try_shoot():
	if dead or !can_shoot or is_reloading:
		return

	can_shoot = false
	current_ammo -= 1
	
	shoot()

	# Auto reload when magazine is empty
	if current_ammo <= 0:
		start_reload()
	else:
		await get_tree().create_timer(fire_rate).timeout
		
		# Ensure we didn't start a manual reload while waiting for the fire_rate timer
		if not is_reloading:
			can_shoot = true


func start_reload():
	if is_reloading:
		return
		
	is_reloading = true
	can_shoot = false
	
	# Optional: You can trigger a reload animation/sound here
	print("Reloading...")
	
	await get_tree().create_timer(reload_time).timeout
	
	if not dead:
		current_ammo = max_ammo
		is_reloading = false
		can_shoot = true
		print("Reload Complete. Ammo: ", current_ammo)


func shoot():
	var bullet = bullet_scene.instantiate()

	get_tree().current_scene.add_child(bullet)

	bullet.global_position = muzzle.global_position

	var dir = (get_global_mouse_position() - muzzle.global_position).normalized()

	bullet.direction = dir
	bullet.rotation = dir.angle()


func take_damage(amount):
	if dead:
		return

	hp -= amount

	start_camera_shake()

	print("Player HP:", hp)

	if hp <= 0:
		die()


func die():
	if dead:
		return

	dead = true
	can_shoot = false
	velocity = Vector2.ZERO

	animated_sprite.play("death")

	await animated_sprite.animation_finished

	get_tree().paused = true


func start_camera_shake():
	current_shake = shake_strength
	shake_time = shake_duration


func update_camera(delta):
	var viewport_size = get_viewport_rect().size
	var screen_center = viewport_size * 0.5

	var mouse = get_viewport().get_mouse_position()

	var offset = mouse - screen_center

	var normalized = Vector2(
		offset.x / screen_center.x,
		offset.y / screen_center.y
	)

	normalized = normalized.limit_length(1.0)

	var deadzone := 0.15
	var length := normalized.length()

	if length < deadzone:
		normalized = Vector2.ZERO
	else:
		length = (length - deadzone) / (1.0 - deadzone)
		normalized = normalized.normalized() * length

	var target_offset = normalized * max_camera_offset

	var final_offset = target_offset

	if shake_time > 0.0:
		shake_time -= delta

		final_offset += Vector2(
			randf_range(-current_shake, current_shake),
			randf_range(-current_shake, current_shake)
		)

		current_shake = lerpf(current_shake, 0.0, delta * 20.0)

	camera.offset = camera.offset.lerp(
		final_offset,
		camera_smoothness * delta
	)
