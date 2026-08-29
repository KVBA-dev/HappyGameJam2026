extends Node

const SPECIAL_CARD_GENERATION := 80
var _ticks = SPECIAL_CARD_GENERATION


func _ready() -> void:
	SignalBus.game_timer_tick.connect(_tick)
	SignalBus.card_binned.connect(_try_to_give_card)
	SignalBus.card_used.connect(_try_to_give_card)

func _tick():
	_ticks = max(_ticks-1, 0)

func can_give_special_card() -> bool:
	return _ticks <= 0 and GameManager.card_holder.count_usable_in_hand() < 1

func _try_to_give_card(..._a):
	var is_special := can_give_special_card()
	var deck := GameManager.usable_cards if is_special else GameManager.cards
	var to_be_added := deck.pick_random_weighted()

	var is_added = GameManager.card_holder.add_card(to_be_added)
	if is_added and is_special: _ticks = SPECIAL_CARD_GENERATION
