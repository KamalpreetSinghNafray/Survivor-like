extends CanvasLayer

const SAVE_PATH = "user://savegame.cfg"

func show_screen(level: int, time: float, contracts: int):
	visible = true
	
	# Calculate score based on our formula
	var current_score = int((level * 100) + (time * 2) + (contracts * 250))
	
	# Load high score
	var high_score = load_high_score()
	
	# Update high score if current run is better
	if current_score > high_score:
		high_score = current_score
		save_high_score(high_score)

	$VBoxContainer/Stats.text = \
		"Score: %d\nHigh Score: %d\nLevel: %d\nTime: %.0f sec" % [
			current_score,
			high_score,
			level,
			time
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

func _process(_delta):
	if visible:
		$VBoxContainer/RestartLabel.modulate.a = \
			0.5 + sin(Time.get_ticks_msec() * 0.005) * 0.5
