extends VBoxContainer

onready var name_label: Label = $name
onready var health_label: Label = $health
onready var action0_label: Label = $action0
onready var action1_label: Label = $action1
onready var action2_label: Label = $action2

var player_id: int
var player_name: String
var health: int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	name_label.text = player_name

func new_actions(actions: Array):
	action0_label.text = actions[0]
	action1_label.text = actions[1]
	action2_label.text = actions[2]

func new_round():
	set_health(3)

func set_health(value: int):
	health = value
	health_label.text = "HP: " + str(health)
