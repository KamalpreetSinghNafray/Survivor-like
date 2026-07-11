extends CanvasLayer

signal choice_selected(choice)

@onready var container: VBoxContainer = $Panel/VBoxContainer
@onready var text: RichTextLabel = $Panel/VBoxContainer/RichTextLabel

var current_choices: Array = []

func show_choices(choices: Array):

	visible = true
	Game_Manager.gameplay_paused = true

	current_choices = choices.duplicate()
	current_choices.shuffle()

	# Remove old buttons
	for child in container.get_children():
		if child != text:
			child.queue_free()

	# Title
	if current_choices.size() > 0:
		if current_choices[0] is UpgradeData:
			text.text = "Select Upgrade"
		elif current_choices[0] is ContractData:
			text.text = "Select Contract"

	# Create buttons
	for choice in current_choices:

		var button := Button.new()
		if choice.title.length() > 2:
			button.custom_minimum_size = Vector2(0, 90)
			button.autowrap_mode = TextServer.AUTOWRAP_OFF
			button.text = "%s\n%s" % [
				choice.title,
				choice.description
			]

			button.pressed.connect(func():
				choice_selected.emit(choice)
				visible = false
				Game_Manager.gameplay_paused = false
			)

			container.add_child(button)
