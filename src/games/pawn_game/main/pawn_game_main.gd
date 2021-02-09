extends Node2D

export (String, DIR) var tile_resource_dir = "res://games/pawn_game/map_components/tiles/tile_resources/"

onready var editor: Control = $pawn_game_ui/map_editor

signal tile_placed(pos, type)
signal preview_tiles(tile_coords, type)

# Called when the node enters the scene tree for the first time.
func _ready():
	var tex = Texture.new()
	print(tex)
	#print(tex.get_class())
# warning-ignore:return_value_discarded
	editor.connect("tile_placed", self, "tile_placed")
# warning-ignore:return_value_discarded
	editor.connect("preview_tiles", self, "preview_tiles")

func tile_placed(pos, type):
	#print("main tile placed")
	emit_signal("tile_placed", pos, type)

func preview_tiles(tile_coords, type):
	emit_signal("preview_tiles", tile_coords, type)

func get_tile_resources():
	var resources: Array = Helpers.load_files_in_dir_with_exts(tile_resource_dir, [".tres"])
	var res_dict: Dictionary = {}
	for res in resources:
		res_dict[res.name] = res
	return res_dict

func round_pos(pos: Vector2, step: int = 20) -> Vector2:
	return Vector2(stepify(pos.x, step), stepify(pos.y, step))
