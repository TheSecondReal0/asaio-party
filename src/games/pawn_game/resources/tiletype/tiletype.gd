tool
extends Resource

class_name TileType

# editor options using export --------------------------------------------------
export (String) var name
export (String, MULTILINE) var desc
# whether or not a pawn can walk through this tile
export var walkable: bool
# whether or not this tile is destructible
export var destructible: bool
#export var health: int

# dict to store editor options added in script ---------------------------------
var editor_properties: Dictionary = {
	"interactions/interactable": "interactable", 
	"interactions/resource": "resource", 
	"interactions/work": "work", 
#	"interactions/mine": "mine", 
	"interactions/deconstruct": "deconstruct", 
#	"interactions/": "", 
	
#	"commands/commandable": "commandable", 
	
	"texture/texture": "texture", 
	"texture/modulate": "modulate",
	"texture/scale": "scale"
	}

# editor options added in script -----------------------------------------------
# whether or not you can tell a pawn to interact with this tile
var interactable: bool
# what resource working this tile gives, leave blank for none
var resource: String
# available orders for pawns to carry out on this tile
var work: bool = false
var deconstruct: bool = false
# whether or not you can command this tile to do something
#var commandable: bool
var texture: Texture = preload("res://games/pawn_game/map_components/tiles/common/textures/square.png")
var modulate: Color = Color(1, 1, 1, 1)
var scale: Vector2 = Vector2(4, 4)

var walkable_path: String = "res://games/pawn_game/map_components/tiles/tile_bases/walkable/walkable.tscn"
var unwalkable_path: String = "res://games/pawn_game/map_components/tiles/tile_bases/unwalkable/unwalkable.tscn"

# store loaded scene
var scene: PackedScene

func gen_tile():
	if scene == null:
		scene = load_scene()
	var tile: Node = scene.instance()
	var sprite: Sprite = tile.get_node("Sprite")
	sprite.texture = texture
	sprite.modulate = modulate
	sprite.scale = scale
	return tile

func gen_sprite(alpha: float = 0.5):
	var sprite: Sprite = Sprite.new()
	sprite.texture = texture
	sprite.modulate = modulate
	sprite.modulate.a = alpha
	sprite.scale = scale
	return sprite

func load_scene():
	print("loading scene")
	if walkable:
		return load(walkable_path)
	if not walkable:
		return load(unwalkable_path)

func _set(property, value):
	if editor_properties.has(property):
		set(editor_properties[property], value)

func _get(property):
	if editor_properties.has(property):
		return get(editor_properties[property])

func _get_property_list():
	var property_list: Array = []
	for property in editor_properties:
		var entry: Dictionary = {}
		var type: int = typeof(get(editor_properties[property]))
		if type == TYPE_OBJECT:
			var property_class: String = get(editor_properties[property]).get_class()
			if ClassDB.instance(property_class) is Texture:
				property_class = "Texture"
			entry["hint"] = PROPERTY_HINT_RESOURCE_TYPE
			entry["hint_string"] = property_class
		entry["name"] = property
		entry["type"] = type
		property_list.append(entry)
	return property_list
