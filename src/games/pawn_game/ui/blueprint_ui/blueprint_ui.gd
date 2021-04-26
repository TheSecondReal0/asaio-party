extends Control

onready var main: Node2D = get_parent().main

var selected: TileBlueprint

var is_mouse_down: bool = false
var mouse_down_pos: Vector2 = Vector2(0, 0)

var preview_blueprint_coords: Array = []

signal blueprint_placed(pos, blueprint)
signal preview_blueprints(tile_coords, blueprint)

func _process(_delta):
	if selected == null:
		return
	var mouse_pos: Vector2 = main.get_global_mouse_position()
	var preview_coords: Array = []
	if not is_mouse_down:
		preview_coords.append(round_pos(mouse_pos))
		emit_signal("preview_tiles", preview_coords, selected)
		return
	else:
		preview_coords = get_tile_positions(mouse_down_pos, mouse_pos)
	if preview_coords.size() != preview_blueprint_coords.size():# preview_coords != preview_tile_coords:
		emit_signal("preview_tiles", preview_coords, selected)
		preview_blueprint_coords = preview_coords

func _gui_input(event):
	if not event is InputEventMouseButton:
		return
	if selected == null:
		return
	# this node will only get GUI input when a tile is selected, setting it as handled
	# 	prevents this input from becoming a selection box too
	get_tree().set_input_as_handled()
	var mouse_pos: Vector2 = main.get_global_mouse_position()
	#print(mouse_pos)
	match event.button_index:
		BUTTON_LEFT:
			is_mouse_down = event.pressed
			if is_mouse_down:
				#mouse_down_pos = event.global_position
				mouse_down_pos = mouse_pos
				return
			emit_signal("preview_blueprints", [], "")
			var tile_coords: Array = get_tile_positions(mouse_down_pos, mouse_pos)
			for coord in tile_coords:
				emit_signal("blueprint_placed", coord, selected)

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