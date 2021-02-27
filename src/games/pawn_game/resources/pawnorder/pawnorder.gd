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
var pawns: Array
