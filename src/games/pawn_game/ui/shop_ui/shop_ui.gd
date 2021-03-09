extends Control

export var pawn_price: int = 1

onready var buy_pawn_button: Button = $Button

signal pawn_purchased

func _ready():
	buy_pawn_button.connect("pressed", self, "buy_pawn_button_pressed")

func buy_pawn_button_pressed():
	emit_signal("pawn_purchased")
