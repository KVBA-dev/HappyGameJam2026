extends Node

const CARD_GENERATION_TICKS := 40
const SPECIAL_CARD_GENERATION := 120

var cards_giver := TickHelper.new(CARD_GENERATION_TICKS)
var special_cards_giver := TickHelper.new(SPECIAL_CARD_GENERATION)

func _ready() -> void:
	cards_giver.timeout.connect(add_placable_card)
	special_cards_giver.timeout.connect(add_usable_card)

func add_placable_card():
	var is_added = GameManager.card_holder.add_card(GameManager.cards.pick_random_weighted())
	if not is_added: cards_giver.fire_next_tick()

func add_usable_card():
	var is_added = GameManager.card_holder.add_card(GameManager.usable_cards.pick_random_weighted())
	if not is_added: special_cards_giver.fire_next_tick()
