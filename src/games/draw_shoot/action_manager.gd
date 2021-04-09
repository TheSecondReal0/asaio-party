extends Node

var player_actions: Dictionary = {}
var round_player_actions: Dictionary = {}
var current_player_actions: Dictionary = {}

var player_health: Dictionary = {}

var drawn: Array = []
var aiming: Array = []
var dodging: Array = []

var shooting: Dictionary = {}
var staring: Dictionary = {}
var was_staring: Dictionary = {}
var rushing: Dictionary = {}
var rushing_2: Dictionary = {}

var current_action: int = 0

# warning-ignore:unused_signal
signal player_damaged(player_id)

func _ready():
	for id in Network.get_peers():
		player_health[id] = 3

func new_actions(new_actions):
	player_actions = new_actions.duplicate()
	update_round_player_actions()
	for i in [0, 1, 2]:
		current_action = i
		setup_for_next_actions()

func execute_actions():
	var player_damage: Dictionary = {}
	print("players getting stared at: ", was_staring.values())
	for player in was_staring.values():
		if player in dodging:
			dodging.erase(player)
		if player in rushing:
			rushing.erase(player)
		if player in rushing_2:
			rushing_2.erase(player)
	for player in shooting:
		var target: int = shooting[player]
		if target in dodging:
			continue
		if target in rushing:
			rushing.erase(player)
		if target in rushing_2:
			rushing_2.erase(player)
		

func setup_for_next_actions():
	was_staring.clear()
	was_staring = staring.duplicate()
	for list in [dodging, shooting, staring, rushing_2]:
		list.clear()
	setup_lists(current_action)

func setup_lists(round_num: int = current_action):
	current_player_actions = round_player_actions[round_num].duplicate()
	for player in current_player_actions:
		var action: String = current_player_actions[player]
		var found_in_match: bool = false
		match current_player_actions[player]:
			"Draw":
				if not player in drawn:
					drawn.append(player)
					found_in_match = true
			"Aim":
				if not player in aiming:
					aiming.append(player)
					found_in_match = true
			"Dodge":
				if not player in dodging:
					dodging.append(player)
					found_in_match = true
		if found_in_match:
			continue
		var target_id: int = int(action.split(" ")[1])
		if "Shoot" in action:
			if player in drawn:
				shooting[player] = target_id
		if "Stare" in action:
			staring[player] = target_id
		if "Rush" in action:
			if player in rushing.keys():
# warning-ignore:return_value_discarded
				rushing.erase(player)
				rushing_2[player] = target_id
			else:
				rushing[player] = target_id

func update_round_player_actions():
	round_player_actions.clear()
	for i in [0, 1, 2]:
		round_player_actions[i] = {}
		for player in player_actions:
			round_player_actions[i][player] = player_actions[player][i]
	print(round_player_actions)

func new_round():
	for list in [aiming, dodging, shooting, staring, was_staring, rushing, rushing_2]:
		list.clear()
