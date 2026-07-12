extends CanvasLayer

func show_screen(level: int, time: float, contracts: int):
	print("showing death screen")
	visible = true

	$VBoxContainer/Stats.text = \
		"Level %d\nTime %.0f sec\nContracts %d" % [
			level,
			time,
			contracts
		]


func _unhandled_input(event):

	if !visible:
		return

	if event.is_action_pressed("restart"):
		Game_Manager.reset_run()
		get_tree().reload_current_scene()

func _process(_delta):

	if visible:
		$VBoxContainer/RestartLabel.modulate.a = \
			0.5 + sin(Time.get_ticks_msec() * 0.005) * 0.5
