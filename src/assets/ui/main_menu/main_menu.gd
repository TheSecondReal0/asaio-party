extends Control

func _ready():
	#hide dropper in ColorPicker
	get_node("ColorPicker/@@11/@@13").hide()
	#give color rect literally any fucking height
	get_node("ColorPicker/@@11/@@12").rect_min_size.y = 30

func _on_Button_pressed():
	if $name.text != "":
		Network.myName = $name.text
		Network.myColor = $ColorPicker.color
		Network.client($ip.text)

func _on_hostButton_pressed():
	if $name.text != "":
		Network.myName = $name.text
		Network.myColor = $ColorPicker.color
		Network.host()
