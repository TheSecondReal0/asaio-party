extends CanvasLayer

export(int, 1, 5) var card_dupes = 3
export(int, 1, 5) var hand_size = 2
export(bool) var shuffle_after_challenge_reveal = false
export(String, DIR) var cards_dir
export(String, FILE, "*.tres") var implied_card
export(String, DIR) var actions_dir
export(Array) var action_order

var implied_card_res = load(implied_card)
var players: Array = Network.get_peers()
var cards: Dictionary = {}
var deck: Array = []
var hands: Dictionary = {}

func setup():
	update_cards()
	print("cards: ", cards)
	init_deck()
	print("deck: ", deck)
	deal_cards()
	print("deck: ", deck)
	print("hands: ", hands)

func deal_cards():
	players = [1,2,3,4,5,6]
	hands = {}
	for _i in hand_size:
		for p in players:
			deal_top(p)

func deal_top(player: int):
	deal(deck.pop_front(), player, true)

func deal(card: String, player: int, erased: bool = false):
	if not erased:
		deck.erase(card)
	if not hands.keys().has(player):
		hands[player] = []
	hands[player].append(card)

func init_deck():
	deck = []
	for card in cards.keys():
		for _i in card_dupes:
			deck.append(card)
	shuffle_deck()

func shuffle_deck():
	deck.shuffle()

func update_cards() -> void:
	cards = {}
	for res in get_card_resources():
		var res_name: String = res.get_name()
		cards[res_name] = res
	#return cards

func get_card_res_from_name(card_name: String):
	return cards[card_name]

func get_card_resources() -> Array:
	var paths = get_card_resource_paths()
	var resources: Array = []
	
	for path in paths:
		var resource = load(path)
		resources.append(resource)
	
	print("card resources: ", resources)
	return resources

func get_card_resource_paths() -> Array:
	var paths: Array = []
	var dir = Directory.new()
	dir.open(cards_dir)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			# completely break out of the loop
			break
		if not file.ends_with(".tres") or not file.ends_with("res"):
			# stop this iteration, but keep the loop going
			continue
		var path: String = cards_dir + "/" + file
		if path == implied_card:
			continue
		paths.append(path)
	
	dir.list_dir_end()
	print("card paths: ", paths)
	return paths
