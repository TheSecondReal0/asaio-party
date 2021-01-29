extends Node2D

var tile_resources: Dictionary
# {Vector2: tile type name}
var map_tiles: Dictionary = {}

signal tile_changed(pos, old_type, new_type)

func place_tiles(start_pos: Vector2, end_pos: Vector2, type: String):
	pass

func place_tile(pos: Vector2, type: String):
	var old_type
	if map_tiles.has(pos):
		old_type = map_tiles[pos]
	else:
		old_type = null
	emit_signal("tile_changed", pos, old_type, type)

func round_pos(pos: Vector2, step: int = 20) -> Vector2:
	return Vector2(stepify(pos.x, step), stepify(pos.y, step))
