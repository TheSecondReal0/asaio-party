extends KinematicBody2D

export var speed: int = 50
export var inaccuracy_denom: int = 15

var path: PoolVector2Array

var pos_dif_history: PoolIntArray

# Called when the node enters the scene tree for the first time.
func _ready():
	if name == "pawn_basic":
		$Polygon2D.color = Color(0, 1, 0)
	pass # Replace with function body.

func _physics_process(delta):
	# if nowhere to go, don't move lol
	if path.empty():
		# eventually add lookout mechanics/when standing still shoot at whatever you can
		return
	# first coord in path is current target
	var target: Vector2 = path[0]
	# if you're already where the current target would take you
	if (target / inaccuracy_denom).round() == (global_position / inaccuracy_denom).round():
		# if this is the last target
		if path.size() < 2:
			return
		#print("at current target, removing coord")
		path.remove(0)
		#print(path)
		target = path[0]
	look_at(target)
	var dir_to: Vector2 = global_position.direction_to(target)
	var distance_to: float = global_position.distance_to(target)
	# clamped to avoid pawn from constantly missing target
	var travel_vec: Vector2 = (dir_to * speed).clamped(distance_to / delta)
	# move in dir, collide and slide against anything in the way
	var pos_dif = move_and_slide(travel_vec)
	if pos_dif_history.size() > 4:
		pos_dif_history.remove(0)
	pos_dif_history.append(pos_dif.length())
	var avg: int = avg_array(pos_dif_history)
	var is_moving: bool = avg > 5
	if not is_moving and path.size() == 1:
		path = []
	if name == "pawn_basic":
		#print(pos_dif_history)
		print(avg)

func avg_array(array) -> int:
	var sum: int = 0
	for i in array:
		sum += i
	return sum / array.size()
