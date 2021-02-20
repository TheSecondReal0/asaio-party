extends Node2D

onready var camera: Camera2D = get_parent().get_node("pawn_game_cam")
onready var interact_popup: Control = $CanvasLayer/interact_popup#$interact_popup

signal interaction_selected(interaction, tile)

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("tile_created", self, "tile_created")
# warning-ignore:return_value_discarded
	interact_popup.connect("interaction_selected", self, "interaction_selected")

func tile_interacted_with(tile: Node2D, input: InputEventMouseButton):
	print(tile, " interacted with")
	print(tile.interactions)
	# uncomment for crash, used for testing
	#print(get_node_or_null("sdgf").x)
	interact_popup.show_interactions(tile.interactions, input.position, tile)

func tile_created(tile):
	tile.connect("interacted_with", self, "tile_interacted_with")

func interaction_selected(interaction, tile):
	emit_signal("interaction_selected", interaction, tile)
