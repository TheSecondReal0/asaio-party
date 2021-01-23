extends KinematicBody2D

export var speed: int = 50

var path: PoolVector2Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	# if nowhere to go, don't move lol
	if path.empty():
		# eventually add lookout mechanics/when standing still shoot at whatever you can
		return
	# first coord in path is current target
	var target: Vector2 = path[0]
	# if you're already where the current target would take you
	if (target / 10).round() == (global_position / 10).round():
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
	move_and_slide(travel_vec)
