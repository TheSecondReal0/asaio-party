extends Resource

class_name PawnOrder

export var order_name: String
enum PATHING_TYPES {EDGE, CENTER}
export(PATHING_TYPES) var pathing_type
export var use_tile_groups: bool = false
export var work_amount: int = 0
export var replaces_tile: bool = false
export var replacement: String = "Grass"
export var gives_item: bool = false
export var given_item: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
