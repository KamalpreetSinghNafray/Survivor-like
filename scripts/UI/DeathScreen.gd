extends CanvasLayer

@onready var restart_label = $VBoxContainer/RestartLabel
const SAVE_PATH = "user://savegame.cfg"

func show_screen(level: int, time: float, contracts: int):
	print("showing death screen")
	visible = true
	get_tree().paused = true
	# Load high score from the file
	var high_score = load_high_score()
	
	# Update high score if the current level is higher
	if level > high_score:
		high_score = level
		save_high_score(high_score)

	# Format the text to show both scores
	$VBoxContainer/Stats.text = \
		"Current Level: %d\nHigh Score: %d\nTime: %.0f sec\nContracts: %d" % [
			level,
			high_score,
			time,
			contracts
		]

func save_high_score(score: int):
	var config = ConfigFile.new()
	config.set_value("player", "high_score", score)
	config.save(SAVE_PATH)

func load_high_score() -> int:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return 0 # No save file exists yet
	return config.get_value("player", "high_score", 0)

func _input(event):
	if !visible:
		return

	if event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled() 
		Game_Manager.reset_run()
		get_tree().reload_current_scene()

func _process(delta):
	print("tick")
	if visible:
		var alpha := 0.6 + 0.4 * sin(Time.get_ticks_msec() * 0.008)
		restart_label.modulate.a = alpha
