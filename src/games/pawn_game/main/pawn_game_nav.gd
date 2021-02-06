extends Navigation2D

onready var map: Node2D = $pawn_game_map
onready var line: Line2D = $Line2D
onready var pawns = $pawn_controller

var start: Vector2 = Vector2(200, 50)
var end: Vector2 = Vector2(974, 550)

# {id: NavigationPolygonInstace}
# so we can check if the node is null (has been freed) and remove its navpoly
var nav_owners: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	map.connect("new_nav_poly_instance", self, "new_nav_poly_instance")
	direct_pawns_to(Vector2(rand_range(50, 974), rand_range(50, 550)), true)

# warning-ignore:unused_argument
func _process(delta):
	input()

func input() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	if Input.is_action_just_pressed("right_click"):
		print("right click, mouse pos: ", mouse_pos)
		direct_pawns_to(mouse_pos)#, true)
	#if Input.is_action_just_pressed("left_click"):
	#	print("left click, mouse pos: ", mouse_pos)
	#	direct_pawns_to(mouse_pos, true)#, true)
		#handle_new_movement(mouse_pos)

func direct_pawns_to(pos: Vector2, rand_start: bool = false):
	print("directing pawns to ", pos)
	if rand_start:
		rand_pawn_pos()
	for pawn in pawns.get_children():
		if pawn.selected:
			var pawn_pos: Vector2 = pawn.global_position
			var path: PoolVector2Array = path(pawn_pos, pos)
			pawn.path = path

func rand_pawn_pos():
	print("randomizing pawn locations")
	for pawn in pawns.get_children():
		pawn.global_position = Vector2(rand_range(50, 974), rand_range(50, 550))

func random_path() -> PoolVector2Array:
	random()
	return path()

func path(start_coord: Vector2 = start, end_coord: Vector2 = end)-> PoolVector2Array:
	return get_simple_path(start_coord, end_coord, true)

func random():
	start = Vector2(rand_range(50, 974), rand_range(50, 550))
	end = Vector2(rand_range(50, 974), rand_range(50, 550))

func update_nav_polygons():
	for id in nav_owners:
		if nav_owners[id] == null:
			navpoly_remove(id)
# warning-ignore:return_value_discarded
			nav_owners.erase(id)

func new_nav_poly_instance(instance: NavigationPolygonInstance):
	update_nav_polygons()
	var id: int = navpoly_add(instance.navpoly, instance.transform, instance)
	nav_owners[id] = instance
