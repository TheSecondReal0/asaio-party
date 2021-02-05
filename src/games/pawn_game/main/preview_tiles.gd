extends Node2D

export var main_path: NodePath

onready var main: Node2D = get_node(main_path)
onready var tile_resources: Dictionary = get_tile_resources()

var preview_tiles: Dictionary = {}
var preview_tile_coords: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	main.connect("preview_tiles", self, "preview_tiles")

func preview_tiles(tile_coords, type):
	clear_preview_tiles()
	preview_tiles_from_array(tile_coords, type)

func preview_tiles_from_coords(start_pos: Vector2, end_pos: Vector2, type: String, step: int = 20):
	preview_tiles_from_array(get_tile_positions(start_pos, end_pos, step), type)
	#for coord in get_tile_positions(start_pos, end_pos, step):
	#	preview_tiles[coord] = preview_tile(coord, type)

func preview_tiles_from_array(array: Array, type: String):
	for coord in array:
		if not coord in preview_tiles:
			preview_tiles[coord] = preview_tile(coord, type)

func preview_tile(pos: Vector2, type: String) -> Sprite:
	var sprite: Sprite = gen_preview_tile(type)
	add_child(sprite)
	sprite.global_position = pos
	return sprite

func clear_preview_tiles():
	for tile in preview_tiles.values():
		tile.queue_free()
	preview_tiles.clear()

func gen_preview_tile(type: String) -> Node:
	var tile: Node = tile_resources[type].gen_sprite()
	#add_child(tile)
	return tile

func get_tile_resources():
	return main.get_tile_resources()

func get_tile_positions(start_pos: Vector2, end_pos: Vector2, step: int = 20):
	start_pos = round_pos(start_pos)
	end_pos = round_pos(end_pos)
	var tile_coords: Array = []
	var top_left: Vector2 = Vector2(min(start_pos.x, end_pos.x), min(start_pos.y, end_pos.y))
	var bottom_right: Vector2 = Vector2(max(start_pos.x, end_pos.x), max(start_pos.y, end_pos.y))
	var dif: Vector2 = bottom_right - top_left
	var tile_dif: Vector2 = dif / step
	for x_tile in tile_dif.x + 1:
		for y_tile in tile_dif.y + 1:
			tile_coords.append(top_left + Vector2(x_tile * step, y_tile * step))
	return tile_coords

func round_pos(pos: Vector2, step: int = 20) -> Vector2:
	return main.round_pos(pos, step)
