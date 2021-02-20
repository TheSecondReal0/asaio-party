extends Node2D

onready var main: Node2D = get_parent().get_parent()
onready var nav: Navigation2D = get_parent()
onready var map: Node2D = get_node("../pawn_game_map")

var selected_pawns: Dictionary = {}

# storage of coords not to path pawns to, nodes keyed by coord
var reserved_coords: Dictionary = {}

# coords pawns are chillin in, nodes keyed by coord
var occupied_coords: Dictionary = {}

var pathing_cache: Dictionary = {}

# warning-ignore:unused_signal
signal command_issued(command_data)

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	main.connect("interaction_selected", self, "interaction_selected")
	for pawn in get_children():
		pawn.connect("selected", self, "pawn_selected", [pawn])
		pawn.connect("deselected", self, "pawn_deselected", [pawn])

func _physics_process(_delta):
	for pawn in pathing_cache:
		var coord: Vector2 = pathing_cache[pawn]
		#print("directing pawn to ", coord)
		#print(nav.path(pawn.global_position, coord))
		nav.direct_pawn_to(pawn, coord)
	pathing_cache.clear()

func interaction_selected(interaction: String, tile: Node2D):
	match interaction:
		"work_all_adjacent":
			var group: Dictionary = map.get_tile_type_group(tile.global_position, tile.type)
			var walkable: Dictionary = map.get_adjacent_walkable_tiles_of_group(group)
			var targets: Array = walkable.keys()
			#print(group)
			#print(walkable)
			var to_assign: Dictionary = selected_pawns.duplicate()
			for pawn in to_assign:
				if targets.empty():
					break
				var coord: Vector2 = targets.pop_back()
				pathing_cache[pawn] = coord#Vector2(200.0, 200)#coord
				#print("directing pawn to ", coord)
				#nav.direct_pawn_to(pawn, coord)
				#walkable.erase(coord)
			

func gen_order_data(interaction: String, tile: Node2D) -> Dictionary:
	var data: Dictionary = {}
	data["action"] = interaction
	data["tile"] = tile
	data["tile_coord"] = tile.global_position
	data["tile_type"] = tile.type
	data["selected_pawns"] = selected_pawns.duplicate()
	data["needs_movement"] = true
	data["pawn_tile_orient"] = "center"
	data["pawns_needed_per_tile"] = 1
	data["tile_group"] = true
	
	match interaction:
		"work":
			data["pawn_tile_orient"] = "edge"
			pass
		"work_all_adjacent":
			data["pawn_tile_orient"] = "edge"
			data["tile_group"] = true
			pass
		"deconstruct":
			data["pawn_tile_orient"] = "edge"
			pass
	
	data["commands"] = gen_commands(data)
	return data

func gen_commands(data: Dictionary):
	# commands keyed by nodes
	var commands: Dictionary = {}
	var pawn_amount: int = data["selected_pawns"].size()
	var targets: Array = []
	if data["tile_group"]:
		var group: Dictionary = map.get_tile_type_group(data["tile_coord"], data["tile_type"])
		var walkable: Dictionary = map.get_adjacent_walkable_tiles_of_group(group)
		targets = walkable.keys()
	else:
		targets = [data["tile_coord"]]
	
	return commands

func gen_command():
	var command: Dictionary = {}
	
	return command

func gen_pathing_targets(data: Dictionary):
	pass

func pawn_selected(pawn: Node):
	#print("pawn selected: ", pawn)
	selected_pawns[pawn] = null
	#print(selected_pawns)

func pawn_deselected(pawn: Node):
	#print("pawn deselected: ", pawn)
# warning-ignore:return_value_discarded
	selected_pawns.erase(pawn)
