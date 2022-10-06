extends Node2D

var player = preload("res://games/bombertron/assets/players/tronBike/tronBike.tscn")

var playerNodes = []

var death_coords: Array = []
var trail_nodes: Array = []

func _init():
	#Ticker.update_tick_rate(0.07)
	set_network_master(1)

puppet func createPlayer(id, pos):
	var newPlayer = player.instance()
	newPlayer.set_network_master(id)
	newPlayer.name = str(id)
	newPlayer.get_node("Polygon2D").color = Network.colors[id]
	#newPlayer.get_node("name").text = Network.names[str(id)]
	$players.add_child(newPlayer)
	newPlayer.global_position = pos
	playerNodes.append(newPlayer)

puppet func deletePlayers():
	death_coords = []
	trail_nodes = []
	for i in $players.get_children():
		i.name = str(i)
		i.queue_free()

puppet func clear_trail():
	for i in get_tree().get_nodes_in_group("trail"):
		i.queue_free()

func _ready():
	set_network_master(1)
