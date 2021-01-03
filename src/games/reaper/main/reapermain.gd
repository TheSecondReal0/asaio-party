extends Node2D

export(String, FILE, "*.tscn") var player_scene_path

onready var movement_target: Node = $movement_target

var player_scene: PackedScene = load("res://games/reaper/player/reaperplayer.tscn")

func setup():
	movement_target.color = Network.get_my_color()
	create_players()

func start():
	pass

func create_players():
	for peer in Network.get_peers():
		create_player(peer)

func create_player(id: int):
	var new_player: Node = player_scene.instance()
	var spawnpoint: Vector2 = Vector2(512, 300)#Vector2(rand_range(100, 924), rand_range(100, 500))
	new_player.name = str(id)
	new_player.color = Network.get_color(id)
	new_player.set_network_master(id)
	$players.add_child(new_player)
	new_player.position = spawnpoint

puppet func create_player_client(id: int, pos: Vector2):
	pass

func handle_new_movement(pos: Vector2):
	movement_target.global_position = pos
	movement_target.show()

func stop_movement():
	movement_target.hide()
