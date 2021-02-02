extends Control

export (String, DIR) var tile_resource_dir

onready var tile_resources: Dictionary = get_tile_resources()
onready var tile_buttons: Node = $CanvasLayer/tile_buttons
onready var map: Node = $map
onready var preview_tiles_node: Node = $preview_tiles

var selected: String = ""

var is_mouse_down: bool = false
var mouse_down_pos: Vector2 = Vector2(0, 0)

var cursor_preview: Sprite
var cursor_preview_pos: Vector2 = Vector2(0, 0)
var preview_tiles: Dictionary = {}
var preview_tile_coords: Array = []

signal tile_placed(pos, type)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(tile_resources)
	map.tile_resources = tile_resources
	#print(tile_resources["Grass"].gen_tile())
# warning-ignore:return_value_discarded
	tile_buttons.connect("type_selected", self, "type_selected")
# warning-ignore:return_value_discarded
	tile_buttons.connect("type_deselected", self, "type_deselected")
	tile_buttons.create_buttons(tile_resources)

func _process(_delta):
	if selected == "":
		return
	var mouse_pos: Vector2 = get_global_mouse_position()
	if cursor_preview == null:
		cursor_preview = gen_preview_tile(selected)
		preview_tiles_node.add_child(cursor_preview)
	cursor_preview.global_position = round_pos(mouse_pos)
	if not is_mouse_down:
		return
	var preview_coords = get_tile_positions(mouse_down_pos, mouse_pos)
	if preview_coords != preview_tile_coords:
		clear_preview_tiles()
		preview_tile_coords = preview_coords
		#preview_tiles(mouse_down_pos, mouse_pos, selected)
		preview_tiles_from_array(preview_tile_coords, selected)
	#print(get_tile_positions(mouse_down_pos, mouse_pos))
	#preview_tile.global_position = preview_tile_pos

func _input(event):
	if not event is InputEventMouseButton:
		return
	var mouse_pos: Vector2 = get_global_mouse_position()
	match event.button_index:
		BUTTON_LEFT:
			is_mouse_down = event.pressed
			if is_mouse_down:
				#mouse_down_pos = event.global_position
				mouse_down_pos = mouse_pos
				return
			if not cursor_preview == null:
				cursor_preview.queue_free()
			var tile_coords: Array = get_tile_positions(mouse_down_pos, mouse_pos)
			clear_preview_tiles()
			for coord in tile_coords:
				emit_signal("tile_placed", coord, selected)
		BUTTON_RIGHT:
			pass
		BUTTON_MIDDLE:
			pass

func preview_tiles_from_coords(start_pos: Vector2, end_pos: Vector2, type: String, step: int = 20):
	preview_tiles_from_array(get_tile_positions(start_pos, end_pos, step), type)
	#for coord in get_tile_positions(start_pos, end_pos, step):
	#	preview_tiles[coord] = preview_tile(coord, type)

func preview_tiles_from_array(array: Array, type: String):
	for coord in array:
		if not coord in preview_tiles:
			preview_tiles[coord] = preview_tile(coord, type)

func preview_tile(pos: Vector2, type: String) -> Sprite:
	var sprite: Sprite = gen_preview_tile(type)
	preview_tiles_node.add_child(sprite)
	sprite.global_position = pos
	return sprite

func clear_preview_tiles():
	for tile in preview_tiles.values():
		tile.queue_free()
	preview_tiles.clear()

func type_selected(type: String):
	selected = type
	#preview_tile = gen_preview_tile(type)
	#grab_focus()

# warning-ignore:unused_argument
func type_deselected(type: String):
	selected = ""
	clear_preview_tiles()
	#grab_focus()

func gen_preview_tile(type: String) -> Node:
	var tile: Node = tile_resources[type].gen_sprite()
	#add_child(tile)
	return tile

func get_tile_resources():
	var resources: Array = Helpers.load_files_in_dir_with_exts(tile_resource_dir, [".tres"])
	var res_dict: Dictionary = {}
	for res in resources:
		res_dict[res.name] = res
	return res_dict

func get_tile_positions(start_pos: Vector2, end_pos: Vector2, step: int = 20):
	start_pos = round_pos(start_pos)
	end_pos = round_pos(end_pos)
	var tile_coords: Array = []
	var top_left: Vector2 = Vector2(min(start_pos.x, end_pos.x), min(start_pos.y, end_pos.y))
	var bottom_right: Vector2 = Vector2(max(start_pos.x, end_pos.x), max(start_pos.y, end_pos.y))
	var dif: Vector2 = bottom_right - top_left
	var tile_dif: Vector2 = dif / step
	for x_tile in tile_dif.x + 1:
		for y_tile in tile_dif.y + 1:
			tile_coords.append(top_left + Vector2(x_tile * step, y_tile * step))
	return tile_coords

func round_pos(pos: Vector2, step: int = 20) -> Vector2:
	return Vector2(stepify(pos.x, step), stepify(pos.y, step))

func get_map_json() -> String:
	return map.tiles_to_json()
	#return ""

# when path selected to save map json to
func _on_FileDialog_file_selected(path):
	print("saving to ", path)
	var map_json = get_map_json()
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(map_json)
	file.close()

func _on_save_button_pressed():
	$CanvasLayer/save_file_dia.popup()

func _on_load_button_pressed():
	$CanvasLayer/load_file_dia.popup()

func _on_load_file_dia_file_selected(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	map.load_from_json(content)
	#return content
