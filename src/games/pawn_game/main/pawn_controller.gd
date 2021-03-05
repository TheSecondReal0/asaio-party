extends Node2D

#export(String, FILE) var pawn_scene_path

onready var main: Node2D = get_parent().get_parent()
onready var nav: Navigation2D = get_parent()
onready var map: Node2D = get_node("../pawn_game_map")
#onready var pawn_scene: PackedScene = load(pawn_scene_path)

var player_pawn_manager_scene: PackedScene = load("res://games/pawn_game/main/player_pawn_manager/player_pawn_manager.tscn")

var selected_pawns: Array = []

# storage of coords not to path pawns to, nodes keyed by coord
var reserved_coords: Dictionary = {}

# coords pawns are chillin in, nodes keyed by coord
var occupied_coords: Dictionary = {}

puppet var player_physics_layers: Dictionary = {}

# player pawn managers keyed by network ID
var managers: Dictionary = {}

# warning-ignore:unused_signal
#signal command_issued(command_data)

# Called when the node enters the scene tree for the first time.
func _ready():
	$player_pawn_manager.queue_free()
# warning-ignore:return_value_discarded
	main.connect("interaction_selected", self, "interaction_selected")
# warning-ignore:return_value_discarded
	main.connect("new_order", self, "new_order")
# warning-ignore:return_value_discarded
	main.connect("box_selection_completed", self, "box_selection_completed")
	var peers: Array = Network.get_peers()
	for i in peers.size():
		# adding 1 so pawns aren't on physics layer used for walls/environment
		player_physics_layers[peers[i]] = pow(2, i + 1)
	print(player_physics_layers)
	if is_network_master():
		rset("player_physics_layers", player_physics_layers)
		rpc("create_pawn_managers", player_physics_layers)

# for when a new order comes in locally AKA from this client
func new_order(order: PawnOrder, pawns: Array = selected_pawns.duplicate()):
	send_order(order, pawns)
	init_order(order, pawns)

# generally initiates orders (gives order info to create commands + issues commands to pawns)
# both for orders created locally and received remotely
func init_order(order: PawnOrder, pawns: Array):
	order.pawn_game_map = map
	#print(pawns)
	var commands: Array = order.create_commands(pawns.duplicate())
	#print(commands)
	for command in commands:
		issue_command(command.pawn, command)

func send_order(order: PawnOrder, pawns: Array):
	var order_data: Dictionary = {}
	var properties: Array = ["order_name", "pawn_movement", "pathing_type", "use_tile_groups", "work_amount", "replaces_tile", "replacement", "gives_item", "given_item", "order_pos"]
	for prop in properties:
		order_data[prop] = order.get(prop)
	var pawn_paths: Array = []
	for pawn in pawns:
		pawn_paths.append(get_path_to(pawn))
	print("sending order, data: ", order_data, "pawn paths: ", pawn_paths)
	rpc("receive_order", order_data, pawn_paths)

remote func receive_order(order_data: Dictionary, pawn_paths: Array):
	print("received order, data: ", order_data, "pawn paths: ", pawn_paths)
	var order: PawnOrder = PawnOrder.new()
	for prop in ["order_name", "pawn_movement", "pathing_type", "use_tile_groups", "work_amount", "replaces_tile", "replacement", "gives_item", "given_item", "order_pos"]:
		order.set(prop, order_data[prop])
	order.tile_node = map.get_tile_node_at(order.order_pos)
	var pawns: Array = []
	for path in pawn_paths:
		pawns.append(get_node(path))
	init_order(order, pawns)

func issue_command(pawn: KinematicBody2D, command: PawnCommand):
	pawn.new_command(command)

func box_selection_completed(start: Vector2, end: Vector2):
	if not Input.is_action_pressed("left_shift"):
		deselect_all_pawns()
	var pawns: Array = get_pawns_between(start, end)
	select_pawns(pawns)

func select_pawns(pawns: Array):
	for pawn in pawns:
		pawn.set_selected(true)

func deselect_all_pawns():
	deselect_pawns(get_my_pawns())

func deselect_pawns(pawns: Array):
	for pawn in pawns:
		pawn.set_selected(false)

func get_pawns_between(pos1: Vector2, pos2: Vector2, error_margin: int = 10) -> Array:
	var pawns: Array = []
	var top_left: Vector2 = Vector2(min(pos1.x, pos2.x) - error_margin, min(pos1.y, pos2.y) - error_margin)
	var bot_right: Vector2 = Vector2(max(pos1.x, pos2.x) + error_margin, max(pos1.y, pos2.y) + error_margin)
	for pawn in get_my_pawns():
		var pos: Vector2 = pawn.global_position
		if pos.x < top_left.x:
			continue
		if pos.y < top_left.y:
			continue
		if pos.x > bot_right.x:
			continue
		if pos.y > bot_right.y:
			continue
		pawns.append(pawn)
	return pawns

puppetsync func create_pawn_managers(physics_layers: Dictionary = player_physics_layers):
	for player_id in physics_layers.keys():
		var manager: Node2D = player_pawn_manager_scene.instance()
		manager.name = str(player_id)
		manager.player_id = player_id
		manager.physics_layer = physics_layers[player_id]
# warning-ignore:return_value_discarded
		manager.connect("pawn_selected", self, "pawn_selected")
# warning-ignore:return_value_discarded
		manager.connect("pawn_deselected", self, "pawn_deselected")
		managers[player_id] = manager
		add_child(manager)

func get_my_pawns() -> Array:
	return get_node(str(Network.get_my_id())).get_children()

func pawn_selected(pawn: Node):
	#print("pawn selected: ", pawn)
	selected_pawns.append(pawn)
	#print(selected_pawns)

func pawn_deselected(pawn: Node):
	#print("pawn deselected: ", pawn)
# warning-ignore:return_value_discarded
	selected_pawns.erase(pawn)
