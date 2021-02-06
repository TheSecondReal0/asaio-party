extends Node2D

onready var area: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	area.connect("input_event", self, "on_area_input_event")

func on_area_input_event(_viewport, event, _shape_index):
	if not event is InputEventMouseButton:
		return
	# doesn't actually change anything, just makes the text prediction stuff work
	event = event as InputEventMouseButton
	match event.button_index:
		BUTTON_LEFT:
			print("left")
			pass
		BUTTON_RIGHT:
			print("right")
			pass
