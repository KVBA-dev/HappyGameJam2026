class_name CursorSelect extends Node2D

var MODULATE_SELECT = Color.hex(0xf4ff0032)

static var selected: Hex 

@onready var hex_sprite = %HexSprite

func _deselect():
	if selected:
		selected.deselect()
		SignalBus.hex_deselected.emit(selected) 
	selected = null
	hide()

func on_select(hex: Hex):
	if not hex or hex == selected:
		_deselect()
		return
	_deselect()

	selected = hex
	selected.select()
	SignalBus.hex_selected.emit(selected)
	hex_sprite.global_position = hex.global_position
	show()
