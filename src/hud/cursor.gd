class_name Cursor extends Node2D

enum Mode {
	HOVER = 0,
	CARD_PLACE_HINT = 2,
	CARD_USE_HINT = 3
}

signal mode_changed(current: Mode, previous: Mode)

var _mode: Mode = Mode.HOVER
var mode: Mode:
	get: return _mode
	set(nmode):
		if nmode == _mode: return 
		mode_changed.emit(nmode, _mode)
		_mode = nmode
		_on_mode_changed()

var block_selection: bool = false

@onready var sprite: Sprite2D = %HexSprite.background_sprite
@onready var cursor_hover: Node2D = %CursorHoverHex
@onready var cursor_select: CursorSelect = %CursorSelect

var MODULATE_NEUTRAL = Color.hex(0x00ffff64)
var MODULATE_GOOD = Color.hex(0x00f51d64)
var MODULATE_BAD = Color.hex(0xf4000264)

func _ready() -> void:
	SignalBus.hex_hovered.connect(_on_hovered)
	SignalBus.card_used_animation_started.connect(func(_u1): mode = Mode.HOVER)
	SignalBus.card_binned.connect(func(..._a): mode = Mode.HOVER)
	GameManager.card_holder.card_returned_to_hand.connect(func(_card): mode = Mode.HOVER)
	GameManager.card_holder.card_dragged.connect(func(card: CardHudBase):
		match card.card_data.type:
			CardData.Type.USABLE: mode = Mode.CARD_USE_HINT
			CardData.Type.PLACABLE: mode = Mode.CARD_PLACE_HINT
	)

	cursor_hover.hide()

static var hover_hex: Hex = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select_hex") \
		and mode == Mode.HOVER \
		and not block_selection \
		and not GameManager.card_holder.is_interacted_with():
		cursor_select.try_to_select(hover_hex)

func _process(_delta: float) -> void:
	scale = get_viewport().get_camera_2d().scale
	match mode:
		Mode.HOVER: 			_hover_process()
		Mode.CARD_PLACE_HINT: 	_hover_process()
		Mode.CARD_USE_HINT:		_hover_process()

func _find_hex() -> Hex:
	var selected_hex_position := HexVector.position_to_hex(get_global_mouse_position())
	return GameManager.hex_grid.get_hex_at(selected_hex_position)

func _hover_process():
	var selected_hex := _find_hex()
	_change_selected(selected_hex)
	_modulate_accordingly(selected_hex)

func _change_selected(hex: Hex):
	if hover_hex == hex: return
	hover_hex = hex

	if hex != null:
		SignalBus.hex_hovered.emit(hover_hex)
		show_tooltip()
	else:
		cursor_hover.hide()
		hide_tooltip()

func _on_hovered(hex: Hex):
	if hex == null:
		return

	_modulate_accordingly(hex)
	cursor_hover.global_position = hex.global_position
	_show(hex)

func _show(hex: Hex):
	var player: AnimationPlayer = hex.animation_player
	if player.is_playing() and player.current_animation != "spawn_above":
		cursor_hover.hide()
		player.animation_finished.connect(func(_anim): cursor_hover.show(), CONNECT_ONE_SHOT)
	else:
		cursor_hover.show()

func _modulate_accordingly(hovered: Hex):
	match mode:
		Mode.HOVER:
			sprite.modulate = MODULATE_NEUTRAL
		Mode.CARD_PLACE_HINT:
			if GameManager.card_holder._can_use_card(false) \
				and hovered.type == HexData.Type.BLANK:
				sprite.modulate = MODULATE_GOOD
			else:
				sprite.modulate = MODULATE_BAD
		Mode.CARD_USE_HINT:
			sprite.modulate = MODULATE_NEUTRAL

func _on_mode_changed():
	if hover_hex != null:
		_modulate_accordingly(hover_hex)

func show_tooltip():
	if hover_hex:
		var tooltip := TextTooltip.new_instance(str(hover_hex.hex_data.hex_name))
		GameManager.main.tooltip_canvas.show_tooltip(self, tooltip)

func hide_tooltip():
	GameManager.main.tooltip_canvas.hide_tooltip(self)
