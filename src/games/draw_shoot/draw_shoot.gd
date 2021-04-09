extends Control

onready var action_manager: Node = $action_manager
onready var player_panels: Control = $player_panels
onready var action_buttons: Control = $action_buttons
onready var submit_button: Button = $action_buttons/submit

var old_player_actions: Dictionary = {}
var new_player_actions: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func all_actions_received():
	old_player_actions = new_player_actions.duplicate()
	new_player_actions = {}
	new_round(old_player_actions)

func new_round(new_actions: Dictionary):
	action_manager.new_actions(new_actions)
	player_panels.new_player_actions(new_actions)
	action_buttons.new_round()

func check_if_received_all_actions() -> bool:
	for player_id in Network.get_peers():
		print("checking if ", player_id, " has sent actions")
		if not player_id in new_player_actions.keys():
			print("has not sent actions")
			return false
		print("has sent actions")
	return true

func send_actions():
	var actions: Array = action_buttons.get_actions()
	print("sending actions: ", actions)
	rpc("receive_actions", actions, Network.get_my_id())

remotesync func receive_actions(actions: Array, player_id: int):
	print("received actions from ", player_id, ": ", actions)
	new_player_actions[player_id] = actions
	if check_if_received_all_actions():
		all_actions_received()

func _on_submit_pressed():
	print("submit pressed")
	submit_button.disabled = true
	send_actions()
