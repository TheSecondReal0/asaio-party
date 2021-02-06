extends KinematicBody2D

export var speed: int = 50
export var inaccuracy_denom: int = 15
export var debug_pawn: bool = false

onready var mover: Node = $mover

var selected = false
var old_state
var mousePos:Vector2
var state: int = states.IDLE
enum states {IDLE, MOVING, COMBAT, WORKING, HAULING}

# state the pawn is trying to get to
# for ex. a pawn you told to work a mine would be in state MOVING but trying to get to state WORKING
var target_state: int = -1
var target_state_data: Dictionary = {}

var path: PoolVector2Array setget set_path

# emitted when state changes
signal transitioned(old_state, new_state)

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug_pawn:
		$Polygon2D.color = Color(0, 1, 0)

func _physics_process(delta):
	mover.move(delta)
	if Input.is_action_just_pressed("left_click"):
		selected = false
		mousePos = get_global_mouse_position()
	

func _input(event):
	if event is InputEventMouseButton and event.pressed == false:
		if sign(get_position().x-mousePos.x) == sign(get_global_mouse_position().x - mousePos.x) and sign(get_global_mouse_position().x-mousePos.x) == sign(get_global_mouse_position().x - get_position().x):
			if sign(get_position().y-mousePos.y) == sign(get_global_mouse_position().y - mousePos.y) and sign(get_global_mouse_position().y-mousePos.y) == sign(get_global_mouse_position().y - get_position().y):
				selected = true
			else:
				selected = false
		else:
			selected = false

# only emitting signal allows greatest flexibility/least spaghetti code
# if we end up making more types of pawns that inherit from this script it's easier
func transition(new_state: int):
	old_state = state
	state = new_state
	emit_signal("transitioned", old_state, new_state)

func set_path(new_path):
	mover.path = new_path
