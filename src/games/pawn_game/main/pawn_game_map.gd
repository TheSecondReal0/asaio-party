extends Node2D

export var main_path: NodePath

onready var main: Node2D = get_node(main_path)
onready var tile_resources: Dictionary = main.get_tile_resources()

# {Vector2: tile type name}
var map_tiles: Dictionary = {}
var map_tile_nodes: Dictionary = {}

signal tile_changed(pos, old_type, new_type)
signal new_nav_poly_instance(instance)

func _ready():
# warning-ignore:return_value_discarded
	main.connect("tile_placed", self, "place_tile")

# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("r"):
		print(map_tiles)
		var json = tiles_to_json(map_tiles)
		print(json)
		var tiles = json_to_tiles(json)
		print(tiles)

func place_tile(pos: Vector2, type: String):
	if not tile_resources.has(type):
		print("tile type does not exist")
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
	var tile = create_tile(pos, type)
	map_tile_nodes[pos] = tile
	emit_signal("tile_changed", pos, old_type, type)
	if tile.has_node("NavigationPolygonInstance"):
		emit_signal("new_nav_poly_instance", tile.get_node("NavigationPolygonInstance"))

func create_tile(pos: Vector2, type: String) -> Node:
	pos = round_pos(pos)
	var new_tile: Node = tile_resources[type].gen_tile()
	add_child(new_tile)
	new_tile.global_position = pos
	return new_tile

func load_from_json(json):
	var tile_dict = json_to_tiles(json)
	for key in tile_dict:
		place_tile(key, tile_dict[key])

# warning-ignore:unused_argument
func tiles_to_json(tiles: Dictionary = map_tiles) -> String:
	var json_tiles: Dictionary = {}
	for coord in map_tiles.keys():
		json_tiles[coord_to_str(coord)] = map_tiles[coord]
	var json_str: String = JSON.print(json_tiles)
	return json_str

func json_to_tiles(json: String) -> Dictionary:
	var json_tiles: Dictionary = JSON.parse(json).result
	var tile_dict: Dictionary = {}
	for str_coord in json_tiles:
		tile_dict[str_to_coord(str_coord)] = json_tiles[str_coord]
	return tile_dict

func coord_to_str(coord: Vector2) -> String:
	return str(coord.x) + "," + str(coord.y)

func str_to_coord(string: String) -> Vector2:
	var split = string.split(",")
	return Vector2(int(split[0]), int(split[1]))

func round_pos(pos: Vector2, step: int = 20) -> Vector2:
	return Vector2(stepify(pos.x, step), stepify(pos.y, step))
