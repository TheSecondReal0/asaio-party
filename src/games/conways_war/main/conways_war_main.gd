extends Node2D
class_name ConwayWarMain

# {Vector2: tile object}
var grid: Dictionary = {}
var old_grid: Dictionary = {}
var grid_size: int = 50
var tile_width: int = 10

var advancing: bool = false

var all_grid_coords: PoolVector2Array = get_all_grid_coords()

var time_since_advance: float = 0.0
var time_between_advances:float = 0.1

var  curr_tile: ConwayTile
var curr_adj_tile_coords: PoolVector2Array
var curr_adj_tiles: Array
var curr_adj_amount: int
var curr_adj_owners: Dictionary
var curr_majority_owner: int
var curr_majority_owner_amount: int
var curr_adj_types: Dictionary
var curr_friendly_types: Dictionary
var curr_enemy_types: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 4:
		var start: Vector2 = Vector2(int(stepify(rand_range(10, 480), 10)) + (tile_width / 2), int(stepify(rand_range(0, 480), 10)) + (tile_width / 2))
		place_tile(start, ConwayTile.TYPES.NORMAL, i + 1)
		for coord in get_adjacent_tile_coords(start, false):
			place_tile(coord, ConwayTile.TYPES.NORMAL, i + 1)
#	for coord in [Vector2(25, 25), Vector2(35, 25), Vector2(45, 25), Vector2(25, 35)]:
#		place_tile(coord, ConwayTile.TYPES.NORMAL, 1)
#	for coord in [Vector2(225, 225), Vector2(235, 225), Vector2(245, 225), Vector2(225, 235)]:
#		place_tile(coord, ConwayTile.TYPES.NORMAL, 2)
	pass
#	for coord in get_all_grid_coords():
#		grid[coord] = null

func _process(_delta: float) -> void:
	time_since_advance += _delta
	if Input.is_action_pressed("space"):
		if time_since_advance >= time_between_advances:
			advance()
			time_since_advance = 0.0

func _draw() -> void:
	var tile: ConwayTile
	for coord in grid:
		tile = grid.get(coord, null)
		if tile == null:
			continue
		draw_tile(tile)

func draw_tile(tile: ConwayTile) -> void:
		if tile == null:
			return
		match tile.type:
			ConwayTile.TYPES.NORMAL:
				draw_square(tile.position, tile.get_color())
			ConwayTile.TYPES.FIGHTER:
				draw_square(tile.position, tile.get_color())
				draw_square(tile.position, Color(0, 0, 0), .5)
	

func draw_square(at: Vector2, color: Color, square_scale: float = 1.0) -> void:
	var offset: Vector2 = Vector2(tile_width / 2, tile_width / 2) * square_scale
	var rect: Rect2 = Rect2(at - offset, Vector2(tile_width, tile_width) * square_scale)
	draw_rect(rect, color)



func advance() -> void:
	advancing = true
	old_grid = grid.duplicate()
	#print("advancing")
	# kill stage
	var tile: ConwayTile
	var adjacent_types: Dictionary = {}
	#for coord in old_grid:
		#update_coord_data(coord)
		#decide_death(coord)
	for coord in all_grid_coords:
		update_coord_data(coord)
		handle_live_tile(coord)
		handle_dead_tile(coord)
	
	advancing = false
	update()

func update_coord_data(coord: Vector2, include_diagonals: bool = true) -> void:
	curr_tile = get_tile(coord)
	curr_adj_tile_coords = get_adjacent_tile_coords(coord, include_diagonals)
	curr_adj_tiles = get_adjacent_tiles(coord)
	curr_adj_amount = get_adjacent_amount(coord)
	curr_adj_owners = get_adjacent_owners(coord)
	curr_majority_owner = get_majority_adj_owner(coord)
	curr_majority_owner_amount = get_majority_adj_owner_amount(coord)
	curr_adj_types = get_adjacent_types(coord)
	if curr_tile == null:
		curr_friendly_types.clear()
		curr_enemy_types.clear()
	else:
		curr_friendly_types = get_adjacent_types_owned_by(coord, curr_tile.player)
		curr_enemy_types = get_adjacent_enemy_types(coord, curr_tile.player)





func spread(from: Vector2, to: Vector2) -> void:
	var from_tile: ConwayTile = get_tile(from)
	var new_tile: ConwayTile = ConwayTile.new()
	new_tile.position = to
	new_tile.type = from_tile.type
	new_tile.player = from_tile.player

func kill(at: Vector2) -> void:
	remove_tile(at)

func handle_dead_tile(at: Vector2) -> bool:
	if curr_tile != null:
		return false
	#var adjacent_types: Dictionary = curr_adj_types#get_adjacent_types(at)
	#var adjacent_owners: Dictionary = get_adjacent_owners(at)
	
	#var total_adjacent: int = curr_adj_amount#0
	#for amount in curr_adj_types.values():
	#	total_adjacent += amount
	#var majority_owner: int = get_majority_adj_owner(at)
	#var majority_owner_amount: int = get_majority_adj_owner_amount(at)
	#var friendly_adjacent: int = get_adjacent_amount_owned_by(at, tile.player)
	#var enemy_adjacent: int = total_adjacent - friendly_adjacent
	
	if curr_majority_owner != 0 and curr_majority_owner_amount >= 3:
		place_tile(at, ConwayTile.TYPES.NORMAL, curr_majority_owner)
		return true
	
	return false

func handle_live_tile(at: Vector2) -> bool:
	#var tile: ConwayTile = get_tile(at)
	if curr_tile == null:
		return false
	#var adjacent_types: Dictionary = get_adjacent_types(at)
	#var adjacent_owners: Dictionary = get_adjacent_owners(at)
	#var total_adjacent: int = 0
	#for amount in adjacent_types.values():
	#	total_adjacent += amount
	#var majority_owner: int = get_majority_adj_owner(at)
	#var majority_owner_amount: int = get_majority_adj_owner_amount(at)
	var friendly_adjacent: int = get_adjacent_amount_owned_by(at, curr_tile.player)
	var enemy_adjacent: int = curr_adj_amount - friendly_adjacent
	
	var friendly_fighter_amount: int = curr_friendly_types.get(ConwayTile.TYPES.FIGHTER, 0)
	var enemy_fighter_amount: int = curr_enemy_types.get(ConwayTile.TYPES.FIGHTER, 0)
	
	var kill: bool = false
	
	if enemy_fighter_amount > 0 and curr_tile.type != ConwayTile.TYPES.FIGHTER:
		# kill all adjacent fighters
		# 	RULE: fighters die when they kill something
		for tile in curr_adj_tiles:
			if tile == null:
				#print("null adj tile")
				continue
			if tile.player != curr_tile.player:
				if tile.type == ConwayTile.TYPES.FIGHTER:
					kill(tile.position)
		kill(at)
		kill = true
	
	if enemy_adjacent > friendly_adjacent:
		kill = true
	if friendly_adjacent > 4:
		kill(at)
		return true
	if friendly_adjacent < 2:
		kill(at)
		return true
	
	if kill:
#		for tile in curr_adj_tiles:
#			if tile == null:
#				#print("null adj tile")
#				continue
#			if tile.player != curr_tile.player:
#				if tile.type == ConwayTile.TYPES.FIGHTER:
#					kill(tile.position)
		kill(at)
#		return true
	
	match curr_tile.type:
		ConwayTile.TYPES.NORMAL:
			if not ConwayTile.TYPES.FIGHTER in curr_friendly_types or curr_friendly_types[ConwayTile.TYPES.FIGHTER] == 0:
				place_tile(curr_tile.position, ConwayTile.TYPES.FIGHTER, curr_tile.player)
		ConwayTile.TYPES.FIGHTER:
			if not ConwayTile.TYPES.FIGHTER in curr_friendly_types:
				continue
			if curr_friendly_types[ConwayTile.TYPES.FIGHTER] > 3:
				pass
				kill(curr_tile.position)
				#place_tile(curr_tile.position, ConwayTile.TYPES.NORMAL, curr_tile.player)
	
	return false



func place_tile(at: Vector2, type: int, player: int) -> void:
	#print("placing tile at ", at)
	var tile: ConwayTile = ConwayTile.new()
	tile.position = at
	tile.type = type
	tile.player = player
	
	grid[at] = tile

func remove_tile(at: Vector2) -> void:
	#print("removing tile at ", at)
	grid.erase(at)



func get_majority_adj_owner_amount(at: Vector2, include_diagonals: bool = true, zero_if_tie: bool = true) -> int:
#	var majority_owner: int = curr_majority_owner
	if curr_majority_owner == 0:
		return 0
	return curr_adj_owners[curr_majority_owner]

func get_majority_adj_owner(at: Vector2, include_diagonals: bool = true, zero_if_tie: bool = true) -> int:
	var adj_owners: Dictionary = curr_adj_owners#get_adjacent_owners(at, include_diagonals)
	if adj_owners.empty():
		return 0
	var max_owner: int = adj_owners.keys()[0]
	var max_amount: int = adj_owners[max_owner]
	
	var tie: bool = false
	for id in adj_owners:
		# don't want to declare a tie on the very first check
		if adj_owners[id] == max_amount and id != adj_owners.keys()[0]:
			tie = true
		if adj_owners[id] > max_amount:
			max_amount = adj_owners[id]
			tie = false
	
	if tie:
		return 0
	
	return max_owner

func get_adjacent_owners(at: Vector2, include_diagonals: bool = true) -> Dictionary:
	var owners: Dictionary = {}
	for tile in curr_adj_tiles:
		if tile == null:
			continue
		if not tile.player in owners:
			owners[tile.player] = 0
		owners[tile.player] += 1
	return owners

func get_adjacent_enemy_types(at: Vector2, player: int, include_diagonals: bool = true) -> Dictionary:
	var enemy_types: Dictionary = curr_adj_types.duplicate()
	for type in curr_friendly_types:
		enemy_types[type] -= curr_friendly_types[type]
	return enemy_types

func get_adjacent_types_owned_by(at: Vector2, player: int, include_diagonals: bool = true) -> Dictionary:
	var types: Dictionary = {}
	for tile in curr_adj_tiles:
		if tile == null:
			continue
		if tile.player != player:
			continue
		if not tile.type in types:
			types[tile.type] = 0
		types[tile.type] += 1
	return types

func get_adjacent_types(at: Vector2, include_diagonals: bool = true) -> Dictionary:
	var types: Dictionary = {}
	for tile in curr_adj_tiles:
		if tile == null:
			continue
		if not tile.type in types:
			types[tile.type] = 0
		types[tile.type] += 1
	return types

func get_adjacent_amount_owned_by(at: Vector2, player: int, include_diagonals: bool = true) -> int:
#	var amount: int = 0
#	for tile in curr_adj_tiles:
#		if tile == null:
#			continue
#		if tile.player != player:
#			continue
#		amount += 1
#	return amount
	if not player in curr_adj_owners:
		return 0
	return curr_adj_owners[player]

func get_adjacent_amount(at: Vector2, include_diagonals: bool = true) -> int:
	var amount: int = 0
	for tile in curr_adj_tiles:
		if tile != null:
			amount += 1
	return amount

func get_adjacent_tiles(at: Vector2, include_diagonals: bool = true) -> Array:
	var tiles: Array = []
	for coord in curr_adj_tile_coords:
		tiles.append(get_tile(coord))
	return tiles

func get_adjacent_tile_coords(at: Vector2, include_diagonals: bool = true) -> PoolVector2Array:
	var coords: PoolVector2Array = []
	var new_coord: Vector2
	for i in [1, -1, 0]:
		for j in [1, -1, 0]:
			if i == 0 and j == 0:
				continue
			if not include_diagonals and i != 0 and j != 0:
				continue
			new_coord = at + (Vector2(i, j) * tile_width)
			if not is_inside_grid(new_coord):
				continue
			coords.append(new_coord)
	return coords

func is_inside_grid(coord: Vector2) -> bool:
	return coord <= Vector2(((grid_size - 1) * tile_width) + (tile_width / 2), ((grid_size - 1) * tile_width) + (tile_width / 2)) and coord > Vector2.ZERO

func get_tile(at: Vector2) -> ConwayTile:
	if advancing:
		return old_grid.get(at, null)
	return grid.get(at, null)

func get_all_grid_coords() -> PoolVector2Array:
	var start: Vector2 = Vector2(tile_width / 2, tile_width / 2)
	var coords: PoolVector2Array = []
	for i in grid_size:
		for j in grid_size:
			coords.append(start + (Vector2(tile_width, tile_width) * Vector2(i, j)))
	return coords
