extends CanvasLayer

onready var main: Node2D = get_parent()
onready var interact_popup: PopupMenu = $interact_popup

signal interaction_selected(interaction, tile)
signal new_order(order)

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	main.connect("tile_created", self, "tile_created")
# warning-ignore:return_value_discarded
	interact_popup.connect("interaction_selected", self, "interaction_selected")
# warning-ignore:return_value_discarded
	interact_popup.connect("new_order", self, "new_order")

func tile_interacted_with(tile: Node2D, input: InputEventMouseButton):
	print(tile, " interacted with")
	#print(tile.orders)
	# uncomment for crash, used for testing
	#print(get_node_or_null("sdgf").x)
	interact_popup.show_interactions(tile.orders, input.position, tile)

func tile_created(tile):
	#print("tile created, ", tile)
	tile.connect("interacted_with", self, "tile_interacted_with")

func interaction_selected(interaction, tile):
	emit_signal("interaction_selected", interaction, tile)

func new_order(order: PawnOrder):
	emit_signal("new_order", order)
