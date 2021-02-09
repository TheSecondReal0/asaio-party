extends PopupMenu

signal interaction_selected(interaction)

var mouse_inside: bool = false
var mouse_distance_max: int = 100

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	connect("id_pressed", self, "interaction_selected")
# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "mouse_exited")

func _process(_delta):
	if mouse_inside:
		return
	if get_global_mouse_position().distance_to(rect_position) > mouse_distance_max:
		close()

func interaction_selected(id: int):
	var interaction: String = get_item_text(id)
	print("tile interaction selected: ", interaction)
	emit_signal("interaction_selected", interaction)
	close()

func show_interactions(interactions: Array, pos: Vector2):
	print("showing interactions: ", interactions)
	clear()
	rect_position = pos
	gen_buttons(interactions)
	show()
	grab_focus()
	mouse_inside = true

func gen_buttons(interactions: Array):
	for interaction in interactions:
		add_item(interaction)

func close():
	clear()
	hide()

func mouse_exited():
	mouse_inside = false
