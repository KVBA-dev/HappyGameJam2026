extends CardHudBase

# Override
func start_use_animation():
	var target := Cursor.hover_hex
	# TODO-r: Make it so hexes can't be placed on same tile during animation
	var grid_pos := target.hex_position

	SignalBus.card_used_animation_started.emit(self)
	_reparent_node_for_animation()

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
