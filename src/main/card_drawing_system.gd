extends Node

const SPECIAL_CARD_GENERATION := 30
const NORMAL_CARD_GENERATION := 20

var normal_card_generation = TickHelper.new(NORMAL_CARD_GENERATION)
var special_card_generation = TickHelper.new(SPECIAL_CARD_GENERATION)

func _ready() -> void:
	normal_card_generation.timeout.connect(_try_to_give_card)
	special_card_generation.timeout.connect(_try_to_give_special)

func can_give_special_card() -> bool:
	return GameManager.card_holder.count_usable_in_hand() < 1

func _try_to_give_special():
	if not can_give_special_card():
		special_card_generation.fire_next_tick()
		return

	var to_be_added: CardData = GameManager.usable_cards.pick_random_weighted()
	var is_added = GameManager.card_holder.add_card(to_be_added) != null
	if not is_added: special_card_generation.fire_next_tick()

func _try_to_give_card(..._a):
	var to_be_added: CardData = GameManager.cards.pick_random_weighted()
	var is_added = GameManager.card_holder.add_card(to_be_added) != null
	if not is_added: normal_card_generation.fire_next_tick()
