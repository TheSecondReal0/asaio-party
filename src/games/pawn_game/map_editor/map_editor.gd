extends Control

export var main_path: NodePath

onready var main: Node2D = get_node(main_path)
onready var tile_resources: Dictionary = get_tile_resources()
onready var tile_buttons: Node = $CanvasLayer/tile_buttons
onready var map: Node = get_parent().get_parent().get_node("pawn_game_nav").get_node("pawn_game_map")
onready var preview_tiles_node: Node = $preview_tiles

var selected: String = ""

var is_mouse_down: bool = false
var mouse_down_pos: Vector2 = Vector2(0, 0)

var preview_tile_coords: Array = []

signal tile_placed(pos, type)
signal preview_tiles(tile_coords, type)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(tile_resources)
# warning-ignore:return_value_discarded
	tile_buttons.connect("type_selected", self, "type_selected")
# warning-ignore:return_value_discarded
	tile_buttons.connect("type_deselected", self, "type_deselected")
	tile_buttons.create_buttons(tile_resources)

func _process(_delta):
	if selected == "":
		return
	var mouse_pos: Vector2 = main.get_global_mouse_position()
	var preview_coords: Array = []
	if not is_mouse_down:
		preview_coords.append(round_pos(mouse_pos))
		emit_signal("preview_tiles", preview_coords, selected)
		return
	else:
		preview_coords = get_tile_positions(mouse_down_pos, mouse_pos)
	if preview_coords.size() != preview_tile_coords.size():# preview_coords != preview_tile_coords:
		emit_signal("preview_tiles", preview_coords, selected)
		preview_tile_coords = preview_coords

func _gui_input(event):
	if not event is InputEventMouseButton:
		return
	var mouse_pos: Vector2 = main.get_global_mouse_position()
	#print(mouse_pos)
	match event.button_index:
		BUTTON_LEFT:
			is_mouse_down = event.pressed
			if is_mouse_down:
				#mouse_down_pos = event.global_position
				mouse_down_pos = mouse_pos
				return
			emit_signal("preview_tiles", [], "")
			var tile_coords: Array = get_tile_positions(mouse_down_pos, mouse_pos)
			for coord in tile_coords:
				emit_signal("tile_placed", coord, selected)
		BUTTON_RIGHT:
			pass
		BUTTON_MIDDLE:
			pass

func type_selected(type: String):
	selected = type
	#preview_tile = gen_preview_tile(type)
	mouse_filter = MOUSE_FILTER_STOP
	#grab_focus()

# warning-ignore:unused_argument
func type_deselected(type: String):
	selected = ""
	emit_signal("preview_tiles", [], selected)
	mouse_filter = MOUSE_FILTER_IGNORE
	#grab_focus()

func get_tile_resources():
	return main.get_tile_resources()

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
	return main.round_pos(pos, step)
	#return Vector2(stepify(pos.x, step), stepify(pos.y, step))

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
