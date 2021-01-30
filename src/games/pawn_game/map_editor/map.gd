extends Node2D

var tile_resources: Dictionary
# {Vector2: tile type name}
var map_tiles: Dictionary = {}

var map_tile_nodes: Dictionary = {}

signal tile_changed(pos, old_type, new_type)

func _ready():
	get_parent().connect("tile_placed", self, "place_tile")

func place_tiles(start_pos: Vector2, end_pos: Vector2, type: String):
	pass

func place_tile(pos: Vector2, type: String):
	if not tile_resources.has(type):
		return
	pos = round_pos(pos)
	var old_type
	if map_tiles.has(pos):
		old_type = map_tiles[pos]
	else:
		old_type = null
	if map_tile_nodes.has(pos):
		map_tile_nodes[pos].queue_free()
	map_tiles[pos] = type
	map_tile_nodes[pos] = create_tile(pos, type)
	emit_signal("tile_changed", pos, old_type, type)

func create_tile(pos: Vector2, type: String) -> Node:
	pos = round_pos(pos)
	var new_tile: Node = tile_resources[type].gen_tile()
	add_child(new_tile)
	new_tile.global_position = pos
	return new_tile

func round_pos(pos: Vector2, step: int = 20) -> Vector2:
	return Vector2(stepify(pos.x, step), stepify(pos.y, step))
