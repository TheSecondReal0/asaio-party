extends Control

export (String, DIR) var tile_resource_dir

onready var tile_resources: Dictionary = get_tile_resources()
onready var tile_buttons: Node = $tile_buttons

var selected: String = ""
var preview_tile: Node

signal place_tile(type, pos)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(tile_resources)
	#print(tile_resources["Grass"].gen_tile())
# warning-ignore:return_value_discarded
	tile_buttons.connect("type_selected", self, "type_selected")
# warning-ignore:return_value_discarded
	tile_buttons.connect("type_deselected", self, "type_deselected")
	tile_buttons.create_buttons(tile_resources)

func _process(_delta):
	var mouse_pos: Vector2 = get_global_mouse_position()
	var tile_pos: Vector2 = Vector2(stepify(mouse_pos.x, 20), stepify(mouse_pos.y, 20))
	if preview_tile != null:
		preview_tile.global_position = tile_pos
	#print(tile_pos)

func type_selected(type: String):
	selected = type
	preview_tile = gen_preview_tile(type)

func type_deselected(type: String):
	selected = ""
	preview_tile.queue_free()

func gen_preview_tile(type: String) -> Node:
	var tile: Node = tile_resources[type].gen_tile()
	add_child(tile)
	return tile

func get_tile_resources():
	var resources: Array = Helpers.load_files_in_dir_with_exts(tile_resource_dir, [".tres"])
	var res_dict: Dictionary = {}
	for res in resources:
		res_dict[res.name] = res
	return res_dict
