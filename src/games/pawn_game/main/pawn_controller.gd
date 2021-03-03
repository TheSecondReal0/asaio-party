extends Node2D

export(String, FILE) var pawn_scene_path

onready var main: Node2D = get_parent().get_parent()
onready var nav: Navigation2D = get_parent()
onready var map: Node2D = get_node("../pawn_game_map")
onready var pawn_scene: PackedScene = load(pawn_scene_path)

var selected_pawns: Array = []

# storage of coords not to path pawns to, nodes keyed by coord
var reserved_coords: Dictionary = {}

# coords pawns are chillin in, nodes keyed by coord
var occupied_coords: Dictionary = {}

puppet var player_physics_layers: Dictionary = {}

# warning-ignore:unused_signal
#signal command_issued(command_data)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(Vector2(1, -1) > Vector2(0, 0))
# warning-ignore:return_value_discarded
	main.connect("interaction_selected", self, "interaction_selected")
# warning-ignore:return_value_discarded
	main.connect("new_order", self, "new_order")
# warning-ignore:return_value_discarded
	main.connect("box_selection_completed", self, "box_selection_completed")
	var peers: Array = Network.get_peers()
	for i in peers.size():
		player_physics_layers[peers[i]] = pow(2, i)
	print(player_physics_layers)
	rset("player_physics_layers", player_physics_layers)
	for id in Network.get_peers():
		var node: Node2D = Node2D.new()
		node.name = str(id)
		add_child(node)
	#if get_tree().is_network_server():
	for _i in 50:
		create_pawn(Vector2(rand_range(50, 974), rand_range(50, 550)), Network.get_my_id(), true)

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

#func interaction_selected(interaction: String, tile: Node2D):
#	match interaction:
#		"work_all_adjacent":
#			var group: Dictionary = map.get_tile_type_group(tile.global_position, tile.type)
#			var walkable: Dictionary = map.get_adjacent_walkable_tiles_of_group(group)
#			var targets: Array = walkable.keys()
#			#print(group)
#			#print(walkable)
#			var to_assign: Array = selected_pawns.duplicate()
#			for pawn in to_assign:
#				if targets.empty():
#					break
#				var coord: Vector2 = targets.pop_back()
#				pathing_cache[pawn] = coord#Vector2(200.0, 200)#coord
#				#print("directing pawn to ", coord)
#				#nav.direct_pawn_to(pawn, coord)
#				#walkable.erase(coord)

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

func create_pawn(pos: Vector2, player_id: int, sync_pawn: bool = true):
	var pawn_container: Node2D = get_node(str(player_id))
	var new_pawn: KinematicBody2D = pawn_scene.instance()
	new_pawn.name = "pawn" + str(pawn_container.get_child_count() + 1)
	new_pawn.player_id = player_id
	new_pawn.player_color = Network.get_color(player_id)
	new_pawn.collision_layer = player_physics_layers[player_id]
	new_pawn.collision_mask = pow(2, 21) - 1 - player_physics_layers[player_id]
	new_pawn.controller = self
	new_pawn.nav = nav
# warning-ignore:return_value_discarded
	new_pawn.connect("selected", self, "pawn_selected", [new_pawn])
# warning-ignore:return_value_discarded
	new_pawn.connect("deselected", self, "pawn_deselected", [new_pawn])
	pawn_container.add_child(new_pawn)
	new_pawn.global_position = pos
	if sync_pawn:
		rpc("receive_create_pawn", pos, player_id)

remote func receive_create_pawn(pos: Vector2, player_id: int):
	print("received create pawn")
	create_pawn(pos, player_id, false)

#func gen_order_data(interaction: String, tile: Node2D) -> Dictionary:
#	var data: Dictionary = {}
#	data["action"] = interaction
#	data["tile"] = tile
#	data["tile_coord"] = tile.global_position
#	data["tile_type"] = tile.type
#	data["selected_pawns"] = selected_pawns.duplicate()
#	data["needs_movement"] = true
#	data["pawn_tile_orient"] = "center"
#	data["pawns_needed_per_tile"] = 1
#	data["tile_group"] = true
#	
#	match interaction:
#		"work":
#			data["pawn_tile_orient"] = "edge"
#			pass
#		"work_all_adjacent":
#			data["pawn_tile_orient"] = "edge"
#			data["tile_group"] = true
#			pass
#		"deconstruct":
#			data["pawn_tile_orient"] = "edge"
#			pass
#	
#	data["commands"] = gen_commands(data)
#	return data

#func gen_commands(data: Dictionary):
#	# commands keyed by nodes
#	var commands: Dictionary = {}
#	var pawn_amount: int = data["selected_pawns"].size()
#	var targets: Array = []
#	if data["tile_group"]:
#		var group: Dictionary = map.get_tile_type_group(data["tile_coord"], data["tile_type"])
#		var walkable: Dictionary = map.get_adjacent_walkable_tiles_of_group(group)
#		targets = walkable.keys()
#	else:
#		targets = [data["tile_coord"]]
#	
#	return commands

#func gen_command():
#	var command: Dictionary = {}
#	
#	return command

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
