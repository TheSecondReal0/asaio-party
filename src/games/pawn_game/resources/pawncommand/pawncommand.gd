extends Resource

# the order resource this command came from
var order: Resource
# the pawn this command is assigned to
var pawn: KinematicBody2D

# where the pawn should go
var pawn_pos: Vector2
# position of the object this command is interacting with
# used so pawns can face the tile they're mining, could be used later to make pawns
# 	watch a certain area if we implement view cones
var target_pos: Vector2



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
