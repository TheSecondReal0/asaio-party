extends Node2D

var player = load("res://games/bombertron/assets/players/tronBike/tronBike.tscn")

var playerNodes = []

var death_coords: Array = []
var trail_nodes: Array = []

func setup():
	resetGame()

func resetGame():
	Ticker.update_tick_rate(0.07)
	rpc("resetGame")
	rpc("deletePlayers")
	deletePlayers()
	clear_trail()
	rpc("clear_trail")
	var player_array = get_tree().get_network_connected_peers()
	player_array.append(1)
	for i in player_array:#networkManager.clients:
		createPlayer(i)
	#for i in networkManager.clients:
		#rpc("createPlayer", i)

func createPlayer(id):
	print("creating player " + str(id))
	var newPlayer = player.instance()
	newPlayer.set_network_master(id)
	newPlayer.name = str(id)
	newPlayer.get_node("Polygon2D").color = Network.colors[id]
	#newPlayer.get_node("name").text = networkManager.names[str(id)]
	$players.add_child(newPlayer)
	var new_pos = Vector2(rand_range(124, 900), rand_range(100, 500))
	newPlayer.global_position = new_pos
	playerNodes.append(newPlayer)
	rpc("createPlayer", id, new_pos)

func deletePlayers():
	print("deleting players")
	death_coords = []
	trail_nodes = []
	for i in $players.get_children():
		i.name = str(i)
		i.queue_free()

func clear_trail():
	for i in get_tree().get_nodes_in_group("trail"):
		i.queue_free()

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		resetGame()
