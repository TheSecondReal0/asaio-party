extends Resource

class_name CoupAction

export(String) var name
export(Color) var color = Color(1, 1, 1)
export(String) var action_text
export(String, MULTILINE) var desc

export(bool) var used_on_player = false
export(bool) var shuffle_after = false
export(int) var coin_cost = 0
export(int) var free_coins = 0
export(int) var steal_coins = 0
export(int, 0, 5) var exchange_cards_picked
export(bool) var reveal_card = false

func get_name() -> String:
	return name
