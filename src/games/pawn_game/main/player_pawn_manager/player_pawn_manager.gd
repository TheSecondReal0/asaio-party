extends Node2D

onready var controller: Node2D = get_parent()

var player_id: int
var physics_layer: int

var pawns: Array = []
enum PAWN_TYPES {BASIC, MEDIC, GIANT}
# list of pawns of certain type keyed by type int (based on PAWN_TYPES enum)
var pawns_by_type: Dictionary = {}

var pawns_created: int = 0

var basic_pawn_scene = load("res://games/pawn_game/pawns/pawn_basic/pawn_basic.tscn")

signal pawn_selected(pawn)
signal pawn_deselected(pawn)
signal pawn_died(pawn)

func _ready():
	set_network_master(player_id)
	if is_network_master():
		for _i in 50:
			create_pawn(Vector2(rand_range(50, 974), rand_range(50, 550)))

func create_pawn(pos: Vector2, type: int = PAWN_TYPES.BASIC):
	var new_pawn: KinematicBody2D = get_pawn_scene(type).instance()
	new_pawn.name = "pawn" + str(pawns_created)
	pawns_created += 1
	new_pawn.player_id = player_id
	new_pawn.player_color = Network.get_color(player_id)
	new_pawn.collision_layer = physics_layer
# warning-ignore:narrowing_conversion
	new_pawn.collision_mask = pow(2, 21) - 1 - physics_layer
	new_pawn.controller = controller
	new_pawn.nav = controller.nav
	pawns.append(new_pawn)
	if not type in pawns_by_type:
		pawns_by_type[type] = []
	pawns_by_type[type].append(new_pawn)
	new_pawn.set_network_master(player_id)
# warning-ignore:return_value_discarded
	new_pawn.connect("selected", self, "pawn_selected", [new_pawn])
# warning-ignore:return_value_discarded
	new_pawn.connect("deselected", self, "pawn_deselected", [new_pawn])
# warning-ignore:return_value_discarded
	new_pawn.connect("died", self, "pawn_died", [new_pawn])
	add_child(new_pawn)
	new_pawn.global_position = pos
	if is_network_master():
		rpc("receive_create_pawn", pos, type)

puppet func receive_create_pawn(pos: Vector2, type: int):
	#print("received create pawn")
	create_pawn(pos, type)

func pawn_died(pawn: KinematicBody2D):
	if not is_network_master():
		return
	emit_signal("pawn_died", pawn)
	rpc("receive_pawn_died", get_path_to(pawn))
	pawn.queue_free()
	remove_pawn_null_references()

puppet func receive_pawn_died(pawn_path: String):
	var pawn: KinematicBody2D = get_node(pawn_path)
	emit_signal("pawn_died", pawn)
	pawn.queue_free()
	remove_pawn_null_references()

func remove_pawn_null_references():
	for pawn in pawns:
		if pawn == null:
			pawns.erase(pawn)
	for type in pawns_by_type.keys():
		for pawn in pawns_by_type[type]:
			if pawn == null:
				pawns_by_type[type].erase(pawn)

func get_pawn_scene(type: int) -> PackedScene:
	match type:
		PAWN_TYPES.BASIC:
			return basic_pawn_scene
	return null

func get_pawns_between(pos1: Vector2, pos2: Vector2, error_margin: int = 10) -> Array:
	var list: Array = []
	var top_left: Vector2 = Vector2(min(pos1.x, pos2.x) - error_margin, min(pos1.y, pos2.y) - error_margin)
	var bot_right: Vector2 = Vector2(max(pos1.x, pos2.x) + error_margin, max(pos1.y, pos2.y) + error_margin)
	for pawn in get_children():
		var pos: Vector2 = pawn.global_position
		if pos.x < top_left.x:
			continue
		if pos.y < top_left.y:
			continue
		if pos.x > bot_right.x:
			continue
		if pos.y > bot_right.y:
			continue
		list.append(pawn)
	return list

func pawn_selected(pawn: KinematicBody2D):
	emit_signal("pawn_selected", pawn)

func pawn_deselected(pawn: KinematicBody2D):
	emit_signal("pawn_deselected", pawn)
