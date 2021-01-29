extends KinematicBody2D

export var speed: int = 50
export var inaccuracy_denom: int = 15
export var debug_pawn: bool = false

onready var mover: Node = $mover

var old_state: int
var state: int
enum states {IDLE, MOVING, COMBAT, WORKING, HAULING}

var path: PoolVector2Array setget set_path

var pos_dif_history: PoolIntArray

# emitted when state changes
signal transitioned(old_state, new_state)

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug_pawn:
		$Polygon2D.color = Color(0, 1, 0)

func _physics_process(delta):
	mover.move(delta)

# only emitting signal allows greatest flexibility/least spaghetti code
# if we end up making more types of pawns that inherit from this script it's easier
func transition(new_state: int):
	old_state = state
	state = new_state
	emit_signal("transitioned", old_state, new_state)

func set_path(new_path):
	mover.path = new_path
