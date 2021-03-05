extends KinematicBody2D

export var speed: int = 50
export var max_health: float = 100.0
export var base_damage: float = 20
export var inaccuracy_denom: int = 15
export var debug_pawn: bool = false

onready var mover: Node = $mover
onready var polygon: Polygon2D = $Polygon2D
onready var health_bar: TextureProgress = $healthbar


# pawn controller node in main scene
var controller: Node
# pawn nav node in main scene
var nav: Navigation2D

# network ID of the player who owns this pawn
var player_id: int = 0
var player_color: Color
onready var outline_color: Color = player_color.inverted()
var outline_thickness: float = 1
var pawn_type: int

var selected = false
var old_state
var mousePos:Vector2
var state: int = states.IDLE
enum states {IDLE, MOVING, COMBAT, WORKING, HAULING}

var health: float = max_health

# command the pawn is following
# some orders require multiple states (MOVING to get to tile, then WORKING to work it)
var command: PawnCommand
var last_command: PawnCommand

var path: PoolVector2Array setget set_path

# emitted when state changes
signal transitioned(old_state, new_state)
# emitted when this pawn is selected
signal selected
# emitted when this pawn is deselected
signal deselected
# emitted when this pawn dies lol what a loser
signal died

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	mover.connect("movement_done", self, "movement_done")
# warning-ignore:return_value_discarded
	connect("selected", self, "on_selected")
# warning-ignore:return_value_discarded
	connect("deselected", self, "on_deselected")
	polygon.color = player_color
	update_health_bar()

func _physics_process(delta):
	if state == states.MOVING:
		mover.move(delta)

func _process(_delta):
	health_bar.rect_rotation = -rotation_degrees
	var collision = move_and_collide(Vector2(0,0))
	if collision == null:
		return
	var pawn: KinematicBody2D = collision.collider
	pawn.damage_pawn(base_damage * _delta)
	#print(pawn.health)

func _draw():
	if selected:
		draw_outline()

func new_command(new_command: PawnCommand):
	command = new_command
	if command.nav_target != null:
		nav.request_path_to(command.nav_target, self)

func movement_done():
	transition(states.IDLE)
	last_command = command
	command = null

func damage_pawn(dmg: float):
	change_health(-dmg)

func change_health(dif: float):
	if health == 0.0:
		emit_signal("died")
		return
	health += dif
	if health < 0.0:
		health = 0.0
	if health > max_health:
		health = max_health
	update_health_bar()

func update_health_bar():
	health_bar.value = health
	if health == max_health:
		health_bar.hide()
	else:
		health_bar.show()

func draw_outline():
	var poly = polygon.get_polygon()
	for i in poly.size():
		draw_line(poly[i - 1], poly[i], outline_color, outline_thickness)

func on_selected():
	#polygon.hide()
	update()
	#$Polygon2D.color = Color(0, 1, 0)

func on_deselected():
	polygon.show()
	update()
	#$Polygon2D.color = player_color

# only emitting signal allows greatest flexibility/least spaghetti code
# if we end up making more types of pawns that inherit from this script it's easier
func transition(new_state: int):
	old_state = state
	state = new_state
	emit_signal("transitioned", old_state, new_state)

func set_selected(_selected: bool):
	selected = _selected
	if selected:
		emit_signal("selected")
	else:
		emit_signal("deselected")

func set_path(new_path):
	transition(states.MOVING)
	mover.path = new_path
