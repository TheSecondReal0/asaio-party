extends PanelContainer

onready var button: MenuButton = $MenuButton
onready var popup: PopupMenu = button.get_popup()

var action: String = ""

func _ready():
	button.connect("id_pressed", self, "_on_id_pressed")

func create_items(player_ids: Array):
	popup.clear()
	for id in player_ids:
		var player_name = Network.names[id]
		create_item(player_name, id)

func create_item(text: String, id: int):
	popup.add_item(text, id)

func _on_id_pressed(id: int):
	pass
