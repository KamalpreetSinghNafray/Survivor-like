extends Resource
class_name UpgradeData

@export var id: String
@export var title: String
@export_multiline var description: String

@export var icon: Texture2D

@export_enum(
	"damage",
	"fire_rate",
	"move_speed",
	"max_hp",
	"bullet_speed",
	"bullet_size",
	"xp_multiplier"
)
var effect: String

@export var value: float = 1.0
