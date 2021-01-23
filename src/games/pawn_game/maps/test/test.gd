extends Node2D

onready var nav: Navigation2D = $Navigation2D
onready var line: Line2D = $Line2D
onready var pawns = $pawns

var start: Vector2 = Vector2(200, 50)
var end: Vector2 = Vector2(974, 550)

func _ready():
	end = Vector2(rand_range(50, 974), rand_range(50, 550))
	for pawn in pawns.get_children():
		pawn.global_position = Vector2(rand_range(50, 974), rand_range(50, 550))
	for pawn in pawns.get_children():
		#random()
		start = pawn.global_position
		var path: PoolVector2Array = path()
		#print(path)
		#line.points = path
		pawn.path = path

func _process(delta):
	return
	line_path()

func line_path(random: bool = true):
	if random:
		random()
	var path = path()
	line.points = path

func random_path() -> PoolVector2Array:
	random()
	return path()

func path(start_coord: Vector2 = start, end_coord: Vector2 = end)-> PoolVector2Array:
	#random()
	return nav.get_simple_path(start, end)
	#print(path)
	#line.points = path

func random():
	start = Vector2(rand_range(50, 974), rand_range(50, 550))
	end = Vector2(rand_range(50, 974), rand_range(50, 550))

func _on_Timer_timeout():
	return
	line_path()
