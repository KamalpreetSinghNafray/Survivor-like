extends CanvasLayer

@onready var health_bar: ProgressBar = $"Control/health bar"
@onready var xp_bar: ProgressBar = $"Control/XP Bar"
@onready var lvl_text: RichTextLabel = $Control/LevelText


func update_health(current: int, maximum: int):
	health_bar.max_value = maximum
	health_bar.value = current


func update_xp(current: int, required: int):
	xp_bar.max_value = required
	xp_bar.value = current


func update_lvl(level: int):
	lvl_text.text = "Level: " + str(level)
