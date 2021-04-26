extends HBoxContainer

signal ui_toggled(ui_name)

func _ready():
	for button in get_children():
		button.connect("pressed", self, "button_pressed", [button])

func button_pressed(button: Button):
	emit_signal("ui_toggled", button.name)

func is_release_mode_enabled():
	return get_parent().is_release_mode_enabled()
