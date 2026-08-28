extends Node

const CARD_GENERATION_TICKS := 30
var ticks = CARD_GENERATION_TICKS

func _ready() -> void:
	SignalBus.game_timer_tick.connect(tick)

func tick():
	ticks -= 1
	if ticks <= 0:
		var is_added = GameManager.card_holder.add_card(GameManager.cards.pick_random_weighted())
		if is_added:
			ticks = CARD_GENERATION_TICKS
		else:
			ticks = 0
