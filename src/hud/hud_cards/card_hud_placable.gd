extends CardHudBase

func get_screen_position() -> Vector2:
	return card_holder.cards_container.to_global(position)

# Override
func start_use_animation():
	var target := Hex.currently_hovered
	# TODO-r: Make it so hexes can't be placed on same tile during animation
	var grid_pos := target.hex_position

	_reparent_node_for_animation()

	# Infinite cards for fun
	GameManager.card_holder.add_card(load("res://const_data/cards/test_card.tres"))

	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(func(vec: Vector2): position = vec,
		position,
		grid_pos.to_pixel() + Vector2.UP*40,
		0.3
	)

	tween.finished.connect(func(): 
		SignalBus.card_used.emit(self, grid_pos)
		queue_free()
	)
