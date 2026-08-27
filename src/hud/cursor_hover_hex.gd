class_name CursorHoverHex extends Node2D

enum Mode {
	HOVER = 0,
	SELECTED = 1,
	CARD_PLACE_HINT = 2,
	CARD_USE_HINT = 3
}

signal mode_changed(current: Mode, previous: Mode)

var _mode: Mode = Mode.HOVER
var mode: Mode:
	get: return _mode
	set(nmode):
		if nmode != _mode: mode_changed.emit(nmode, _mode)
		_mode = nmode
		_on_mode_changed()

@onready var sprite: Sprite2D = %HexSprite.background_sprite

var MODULATE_NEUTRAL = Color.hex(0x00ffff32)
var MODULATE_GOOD = Color.hex(0x00f51d32)
var MODULATE_BAD = Color.hex(0xf4000232)
var MODULATE_SELECT = Color.hex(0xf4ff0032)

func _ready() -> void:
	SignalBus.hex_hovered.connect(_on_hovered)
	SignalBus.card_used_animation_started.connect(func(_u1): mode = Mode.HOVER)
	GameManager.card_holder.card_returned_to_hand.connect(func(_card): mode = Mode.HOVER)
	GameManager.card_holder.card_dragged.connect(func(card: CardHudBase):
		match card.card_data.type:
			CardData.Type.USABLE: mode = Mode.CARD_USE_HINT
			CardData.Type.PLACABLE: mode = Mode.CARD_PLACE_HINT
	)

	hide()

static var selected: Hex = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select_hex") and mode in [ Mode.SELECTED, Mode.HOVER ]:
		mode = Mode.SELECTED if mode != Mode.SELECTED else Mode.HOVER

func _process(_delta: float) -> void:
	scale = get_viewport().get_camera_2d().scale
	match mode:
		Mode.HOVER: 			_find_hex()
		Mode.SELECTED: 			pass
		Mode.CARD_PLACE_HINT: 	_find_hex()
		Mode.CARD_USE_HINT:		_find_hex()

func _find_hex():
	var selected_hex_position := HexVector.position_to_hex(get_global_mouse_position())
	var selected_hex := GameManager.hex_grid.get_hex_at(selected_hex_position)

	_change_selected(selected_hex)

func _change_selected(hex: Hex):
	if selected == hex: return
	selected = hex

	if hex != null:
		SignalBus.hex_hovered.emit(selected)
	else:
		hide()

func _on_hovered(hex: Hex):
	if hex == null:
		return

	_modulate_accordingly(hex)
	global_position = hex.global_position
	_show(hex)

func _show(hex: Hex):
	var player: AnimationPlayer = hex.animation_player
	if player.is_playing() and player.current_animation != "spawn_above":
		hide()
		player.animation_finished.connect(func(_anim): show(), CONNECT_ONE_SHOT)
	else:
		show()

func _modulate_accordingly(hovered: Hex):
	match mode:
		Mode.HOVER:
			sprite.modulate = MODULATE_NEUTRAL
		Mode.SELECTED:
			sprite.modulate = MODULATE_SELECT
		Mode.CARD_PLACE_HINT:
			if GameManager.hex_grid.can_place_card(hovered.hex_position) \
				and hovered.type == HexData.Type.BLANK:
				sprite.modulate = MODULATE_GOOD
			else:
				sprite.modulate = MODULATE_BAD
		Mode.CARD_USE_HINT:
			sprite.modulate = MODULATE_NEUTRAL

func _on_mode_changed():
	if selected != null:
		_modulate_accordingly(selected)