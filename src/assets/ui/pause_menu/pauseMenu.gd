extends Control

func _on_Resume_pressed():
	get_parent().closePauseMenu()

func _on_Leave_pressed():
	networkManager.leave()

func _on_Quit_pressed():
	get_tree().quit()
