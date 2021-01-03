extends KinematicBody2D

enum states {standing, moving, dashing}

onready var polygon: Polygon2D = $Polygon2D
onready var particles: CPUParticles2D = $CPUParticles2D
onready var main: Node2D = get_parent().get_parent()

var state: int = states.standing

var color: Color

var speed: float = 50
var dash_distance: int = 50

var moving_to: Vector2 = Vector2(600, 300)

var dashing_to: Vector2 = Vector2()
var dash_progress: int = 0

puppet var slave_pos: Vector2 = Vector2()
puppet var slave_rot: float = 0.0

func _ready():
	polygon.color = color
	particles.color = color

func _physics_process(_delta):
	if state == states.dashing:
#		print("resuming dash")
		dash_to(dashing_to)
		return
	if is_network_master():
		input()
		if state == states.moving:
			move_to(moving_to, _delta)
	else:
		global_position = slave_pos
		global_rotation = slave_rot

func _process(_delta):
	if is_network_master():
		rset("slave_pos", global_position)
		rset("slave_rot", global_rotation)

func input() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	if Input.is_action_just_pressed("left_click"):
		rpc("receive_pos", global_position)
		rpc("start_dash", mouse_pos)
#		dash_to(mouse_pos)
		handle_new_movement(mouse_pos)
	if Input.is_action_just_pressed("right_click"):
		handle_new_movement(mouse_pos)

puppet func receive_pos(pos: Vector2):
	global_position = pos

func move_to(pos: Vector2, delta: float) -> void:
	var distance_to: float = global_position.distance_to(pos)
	var dir: Vector2 = pos_to_dir(pos)
	look_at(pos)
	var used_speed: float = speed
	if distance_to < speed * delta:
		used_speed = distance_to / delta
		stop_movement()
# warning-ignore:return_value_discarded
	move_and_slide(dir * used_speed)

puppetsync func start_dash(pos: Vector2) -> void:
	handle_new_movement(pos)
	dashing_to = pos
	dash_progress = 4
	state = states.dashing
	particles.restart()
	dash_to(pos)

func dash_to(pos: Vector2) -> void:
	var dir: Vector2 = pos_to_dir(pos)
	look_at(pos)
# warning-ignore:return_value_discarded
	move_and_collide(dir * dash_distance / 4)
	dash_progress -= 1
	if dash_progress <= 0:
		state = states.moving

func handle_new_movement(pos: Vector2) -> void:
	if state == states.dashing:
		return
	moving_to = pos
	state = states.moving
	main.handle_new_movement(pos)

func stop_movement() -> void:
	if state == states.dashing:
		return
	state = states.standing
	main.stop_movement()

func pos_to_rot(pos: Vector2) -> float:
	return pos_to_dir(pos).angle()

func pos_to_dir(pos: Vector2) -> Vector2:
	return global_position.direction_to(pos)

func _on_Area2D_body_entered(body):
	print("body entered player ", body)
