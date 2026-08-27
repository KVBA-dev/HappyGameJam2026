extends Node2D

var MODULATE_SELECT = Color.hex(0xf4ff0032)

static var selected: Hex 

func _deselect():
	if selected: selected.deselect()
	selected = null
	hide()

func on_select(hex: Hex):
	if not hex or hex == selected:
		_deselect()
		return
	_deselect()

	selected = hex
	selected.select()
	global_position = hex.global_position
	show()
