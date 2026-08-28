extends CardHudBase

# Override
func start_use_animation():
	var target := Cursor.hover_hex
	# TODO-r: Make it so hexes can't be placed on same tile during animation
	var grid_pos := target.hex_position
	SignalBus.card_used.emit(self, grid_pos)
	queue_free()


