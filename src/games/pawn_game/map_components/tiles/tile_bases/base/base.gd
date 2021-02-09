extends Node2D

onready var interact_area = get_node_or_null("interact_area")

var tile_name: String
var desc: String
# whether or not a pawn can walk through this tile
var walkable: bool
# whether or not this tile is destructible
var destructible: bool
var health: int

# whether or not you can tell a pawn to interact with this tile
var interactable: bool
# what resource working this tile gives, leave blank for none
var resource: String

# list of available interactions
var interactions: Array = []

signal interacted_with(tile_node)

func _ready():
	if interact_area:
		interact_area.connect("clicked", self, "on_clicked")

func on_clicked(input: InputEventMouseButton):
	# we want the ui to open on release
	if input.pressed:
		return
	match input.button_index:
		BUTTON_RIGHT:
			emit_signal("interacted_with", self)
			print(input)

