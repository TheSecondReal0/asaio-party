extends Control

export (String, DIR) var tile_resource_dir

onready var tile_resources: Dictionary = get_tile_resources()
onready var tile_buttons: Node = $tile_buttons

# Called when the node enters the scene tree for the first time.
func _ready():
	print(tile_resources)
	tile_buttons.create_buttons(tile_resources)

func get_tile_resources():
	var resources: Array = Helpers.load_files_in_dir_with_exts(tile_resource_dir, [".tres"])
	var res_dict: Dictionary = {}
	for res in resources:
		res_dict[res.name] = res
	return res_dict
