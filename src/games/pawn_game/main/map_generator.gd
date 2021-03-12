extends Node2D

export var width: int = 100
export var height: int = 60
export var mountain_threshold: float = .1
export var gold_threshold: float = .25

var simplex: OpenSimplexNoise = OpenSimplexNoise.new()
var simplex_seed: int = randi()#2360192022#randi()

var map_coord_noise: Dictionary = {}

var map_gen_order: PoolStringArray = ["Mountain", "Gold"]

var simplex_settings: Dictionary = {
	"Mountain": {
		"lacunarity": 2.0, 
		"octaves": 4, 
		"period": 24.0, 
		"persistence": 0.5
	}, 
	
	"Gold": {
		"lacunarity": 2.0, 
		"octaves": 4, 
		"period": 12.0, 
		"persistence": 0.5
	}, 
}

# Called when the node enters the scene tree for the first time.
func _ready():
#	print(randi())
	pass # Replace with function body.

func generate_map() -> Dictionary:
	var map_layers: Dictionary = {}
	for type in map_gen_order:
		config_simplex(type)
		map_layers[type] = gen_map_noise()
	var map_tile_types: Dictionary = {}
	var mountain_layer: Dictionary = map_layers["Mountain"]
	var gold_layer: Dictionary = map_layers["Gold"]
	for coord in mountain_layer:
		if mountain_layer[coord] > mountain_threshold:
			if gold_layer[coord] > gold_threshold:
				map_tile_types[coord] = "Gold"
				continue
			map_tile_types[coord] = "Mountain"
			continue
		else:
			map_tile_types[coord] = "Grass"
#	for coord in map_coord_noise:
#		map_tile_types[coord] = noise_to_tile_type(map_coord_noise[coord])
	return map_tile_types

func noise_to_tile_type(noise: float):
	var type: String = "Grass"
	if noise < -.1:
		type = "Mountain"
	if noise > .34:
		type = "Gold"
	return type

func gen_map_noise() -> Dictionary:
	var coord_noise = get_coord_noise()
	var map_noise: Dictionary = {}
	for coord in coord_noise:
		map_noise[gen_map_coord(coord)] = coord_noise[coord]
	return map_noise

func get_coord_noise() -> Dictionary:
# warning-ignore:integer_division
# warning-ignore:integer_division
	var top_left: Vector2 = Vector2(width / 2, height / 2) * -1
#	var bot_right: Vector2 = Vector2(width / 2, height / 2) * 20
	var coord_noise: Dictionary = {}
	for x in width:
		for y in height:
			coord_noise[Vector2(top_left + Vector2(x, y))] = simplex.get_noise_2d(x, y)
	return coord_noise

func config_simplex(type: String):
	simplex.seed = simplex_seed
	for prop in simplex_settings[type]:
		simplex.set(prop, simplex_settings[type][prop])

func gen_map_coord(vec: Vector2) -> Vector2:
	return vec * 20
