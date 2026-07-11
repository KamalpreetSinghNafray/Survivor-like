extends Resource
class_name ContractData

@export var id: String
@export var title: String
@export_multiline var description: String
@export var reward_value: float = 1.0
@export var icon: Texture2D

# ---------- Contract Effect ----------

@export_enum(
	"enemy_speed",
	"enemy_health",
	"enemy_damage",
	"spawn_rate",
	"player_hp",
	"glass_cannon",
	"no_heal"
)
var effect: String

@export var value: float = 1.0

# ---------- Reward ----------

@export var reward_title: String
@export_multiline var reward_text: String

@export_enum(
	"damage",
	"fire_rate",
	"move_speed",
	"max_hp",
	"bullet_speed",
	"xp_multiplier",
	"none"
)
var reward_effect: String = "none"
