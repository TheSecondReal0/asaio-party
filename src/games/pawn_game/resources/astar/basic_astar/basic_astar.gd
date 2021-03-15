extends AStar2D

func _compute_cost(_from_id, _to_id):
	var pos1: Vector2 = get_point_position(_from_id)
	var pos2: Vector2 = get_point_position(_to_id)
	if pos1.x != pos2.x and pos1.y != pos2.y:
		return 0.9
	else:
		return 1.0

func _estimate_cost(_from_id, _to_id):
	var pos1: Vector2 = get_point_position(_from_id)
	var pos2: Vector2 = get_point_position(_to_id)
	if pos1.x != pos2.x and pos1.y != pos2.y:
		return 0.9
	else:
		return 1.0
