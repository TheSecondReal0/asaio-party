extends HBoxContainer

var type_dict: Dictionary = {}

signal type_selected(type_res)

func create_buttons(res_dict: Dictionary):
	type_dict = res_dict.duplicate()
	for type in type_dict:
		create_button(type, type_dict[type])

func create_button(type: String, res: Resource):
	var button: Button = Button.new()
	button.text = type
	button.connect("pressed", self, "_on_button_pressed", [res])
	add_child(button)

func _on_button_pressed(res: Resource):
	print("type selected: ", res.name)
	emit_signal("type_selected", res)
