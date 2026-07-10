extends Area2D

@export var speed: float = 900.0
@export var damage: int = 1
@export var life_time: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready():
	body_entered.connect(_on_body_entered)
	
	await get_tree().create_timer(life_time).timeout
	queue_free()

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
