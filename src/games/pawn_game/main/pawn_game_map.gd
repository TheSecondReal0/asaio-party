extends Node2D

export var main_path: NodePath

onready var main: Node2D = get_node(main_path)
onready var tile_resources: Dictionary = main.get_tile_resources()

# {Vector2: tile type name}
var map_tiles: Dictionary = {}
var map_tile_nodes: Dictionary = {}

signal tile_changed(pos, old_type, new_type)
signal tile_created(tile)
signal new_nav_poly_instance(instance)

func _ready():
# warning-ignore:return_value_discarded
	main.connect("tile_placed", self, "place_tile")
# warning-ignore:return_value_discarded
	main.connect("interaction_selected", self, "interaction_selected")

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
		#print("tile type does not exist")
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
	emit_signal("tile_created", tile)
	if tile.has_node("NavigationPolygonInstance"):
		var navpoly = tile.get_node("NavigationPolygonInstance")
		emit_signal("new_nav_poly_instance", navpoly)
		navpoly.enabled = false
		navpoly.enabled = true

func create_tile(pos: Vector2, type: String) -> Node:
	pos = round_pos(pos)
	var new_tile: Node = tile_resources[type].gen_tile()
	#add_child(new_tile)
	call_deferred("add_child", new_tile)
	new_tile.global_position = pos
	return new_tile

func get_tile_type_group(coord: Vector2, type: String, diagonal: bool = true, include_self: bool = true) -> Dictionary:
	var tiles: Dictionary = {}
	var to_check: Array = [coord]
	while not to_check.empty():
		for vec in to_check:
			var adjacent: Dictionary = get_adjacent_tiles_of_type(vec, type, diagonal, include_self)
			for tile_coord in adjacent:
				if tile_coord in tiles:
					continue
				tiles[tile_coord] = adjacent[tile_coord]
				to_check.append(tile_coord)
			to_check.erase(vec)
	return tiles

func get_x_walkable_tiles(coord: Vector2, amount: int, diagonal: bool = false, include_self: bool = true) -> Dictionary:
	var tiles: Dictionary = {}
	var to_check: Array = [coord]
	while tiles.size() < amount:
		var vec = to_check.pop_front()
		tiles[vec] = map_tiles[vec]
		if tiles.size() == amount:
			break
		to_check.append(get_adjacent_walkable_tiles(vec, diagonal, include_self))
	return tiles

func get_adjacent_tiles_of_type(coord: Vector2, type: String, diagonal: bool = true, include_self: bool = false) -> Dictionary:
	var tiles: Dictionary = {}
	var adjacent: Dictionary = get_adjacent_tiles(coord, diagonal, include_self)
	for coord in adjacent:
		if adjacent[coord] == type:
			tiles[coord] = adjacent[coord]
	return tiles

func get_adjacent_walkable_tiles_of_group(tiles: Dictionary, diagonal: bool = false, include_self: bool = false) -> Dictionary:
	var walkable: Dictionary = {}
	for coord in tiles:
		var adjacent: Dictionary = get_adjacent_walkable_tiles(coord, diagonal, include_self)
		for vec in adjacent:
			walkable[vec] = adjacent[vec]
	return walkable

func get_adjacent_walkable_tiles(coord: Vector2, diagonal: bool = false, include_self: bool = false) -> Dictionary:
	var walkable: Dictionary = {}
	var adjacent: Dictionary = get_adjacent_tiles(coord, diagonal, include_self)
	for coord in adjacent:
		if is_tile_type_walkable(adjacent[coord]):
			walkable[coord] = adjacent[coord]
	return walkable

func get_adjacent_tiles(coord: Vector2, diagonal: bool = true, include_self: bool = false) -> Dictionary:
	var tiles: Dictionary = {}
	var factors: Array = [0, 1, -1]
	for x in factors:
		for y in factors:
			if not include_self:
				if x == 0 and y == 0:
					continue
			if not diagonal:
				if x != 0 and y != 0:
					continue
			var current: Vector2 = coord + (Vector2(x, y) * 20)
			if current in map_tiles:
				tiles[current] = map_tiles[current]
	return tiles

func is_tile_type_walkable(type: String):
	return tile_resources[type].walkable

func interaction_selected(interaction, tile):
	pass
	#var tile_coord: Vector2 = tile.global_position
	#var tile_type: String = map_tiles[tile_coord]
	#print(interaction, " ", tile_coord, " ", tile_coord in map_tiles)
	#print(get_adjacent_tiles(tile_coord))
	#print(get_adjacent_tiles_of_type(tile_coord, tile_type))
	#var group: Dictionary = get_tile_type_group(tile_coord, tile_type)
	#print(group)
	#print(get_adjacent_walkable_tiles_of_group(group))

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
