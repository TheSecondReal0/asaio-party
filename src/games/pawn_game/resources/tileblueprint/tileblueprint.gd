extends Resource

class_name TileBlueprint

export var blueprint_text: String
export(String, MULTILINE) var blueprint_desc: String
export var tile_type: Resource
export(Array, String) var buildable_on = ["Grass"]
export var work: int = 10
# resource name: amount needed
export var resource_cost: Dictionary = {
	"Gold": 0
}
