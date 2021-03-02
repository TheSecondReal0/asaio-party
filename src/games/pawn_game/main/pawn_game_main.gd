extends Node2D

export (String, DIR) var tile_resource_dir = "res://games/pawn_game/map_components/tiles/tile_resources/"

onready var map: Node2D = $pawn_game_nav/pawn_game_map
onready var world_ui: Node2D = $world_ui
onready var editor: Control = $pawn_game_ui/map_editor

signal tile_placed(pos, type)
signal preview_tiles(tile_coords, type)
signal tile_created(tile)
signal interaction_selected(interaction, tile)
signal new_order(order)
signal box_selection_completed(start, end)

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	editor.connect("tile_placed", self, "tile_placed")
# warning-ignore:return_value_discarded
	editor.connect("preview_tiles", self, "preview_tiles")
# warning-ignore:return_value_discarded
	map.connect("tile_created", self, "tile_created")
# warning-ignore:return_value_discarded
	world_ui.connect("interaction_selected", self, "interaction_selected")
# warning-ignore:return_value_discarded
	world_ui.connect("new_order", self, "new_order")
# warning-ignore:return_value_discarded
	world_ui.connect("box_selection_completed", self, "box_selection_completed")

func tile_placed(pos, type):
	#print("main tile placed")
	emit_signal("tile_placed", pos, type)

func preview_tiles(tile_coords, type):
	emit_signal("preview_tiles", tile_coords, type)

func tile_created(tile):
	emit_signal("tile_created", tile)

func interaction_selected(interaction, tile):
	emit_signal("interaction_selected", interaction, tile)

func new_order(order: PawnOrder):
	emit_signal("new_order", order)

func box_selection_completed(start: Vector2, end: Vector2):
	emit_signal("box_selection_completed", start, end)

func get_tile_resources():
	var resources: Array = Helpers.load_files_in_dir_with_exts(tile_resource_dir, [".tres"])
	var res_dict: Dictionary = {}
	for res in resources:
		res_dict[res.type] = res
	return res_dict

func round_pos(pos: Vector2, step: int = 20) -> Vector2:
	return Vector2(stepify(pos.x, step), stepify(pos.y, step))
