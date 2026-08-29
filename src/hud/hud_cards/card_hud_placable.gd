extends CardHudBase

func get_screen_position() -> Vector2:
	return card_holder.cards_container.to_global(position)

# Override
func start_use_animation():
	var target := Cursor.hover_hex
	# TODO-r: Make it so hexes can't be placed on same tile during animation
	var grid_pos := target.hex_position

	SignalBus.card_used_animation_started.emit(self)
	_reparent_node_for_animation()

	var saved_pos := position
	var anim_target_pos := grid_pos.to_pixel() + Vector2.UP*40

	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(func(t: float): 
		if infinite_card.value:
			hex_sprite.rainbow_border_sprite.set_instance_shader_parameter("alpha", 1.0 - t)
		position = lerp(saved_pos, anim_target_pos, t),
		0.0,
		1.0,
		0.3
	)

	tween.finished.connect(func(): 
		SignalBus.card_used.emit(self, grid_pos)
		if infinite_card.value:
			_copy_to_hand_holder()
		queue_free()
	)
