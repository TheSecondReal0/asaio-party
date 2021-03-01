extends Resource

class_name PawnOrder

export var order_name: String
export var pawn_movement: bool = true
enum PATHING_TYPES {EDGE, CENTER, POINTER}
export(PATHING_TYPES) var pathing_type
export var use_tile_groups: bool = false
export var work_amount: int = 0
export var replaces_tile: bool = false
export var replacement: String = "Grass"
export var gives_item: bool = false
export var given_item: String

# world position this order was given on (where right click was)
var order_pos: Vector2
# tile node this order was given on (null if does not exist or not applicable)
var tile_node: Vector2
# pawn this order was given on (null if does not exist or not applicable)
var target_pawn: KinematicBody2D

# list of pawns this order is for
var pawns: Array = []

# list of all coords pawns should be moving towards
var pos_targets: Array = []

# pawn_game_map node in main scene
var pawn_game_map: Node2D

func get_pos_targets() -> Array:
	var targets: Array = []
	
	var amount: int = pawns.size()
	
	match pathing_type:
		PATHING_TYPES.EDGE:
			
			pass
		PATHING_TYPES.CENTER:
			
			pass
		PATHING_TYPES.POINTER:
			if amount == 1:
				# return one target which is exactly where the player right clicked
				return [order_pos]
			# get walkable tiles around coord, get perfect amount for the number of pawns
			# 	this order has
			var walkable_tiles: Dictionary = pawn_game_map.get_x_walkable_tiles(order_pos, amount)
			return walkable_tiles.keys()
	return targets
