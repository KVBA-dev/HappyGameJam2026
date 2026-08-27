class_name CursorHoverHex extends Node2D

enum Mode {
	HOVER = 0,
	SELECTED = 1,
	CARD_PLACE_HINT = 2,
	CARD_USE_HINT = 3
}

@onready var sprite: Sprite2D = %HexSprite.background_sprite

var MODULATE_NEUTRAL = Color.hex(0x00ffff32)
var MODULATE_GOOD = Color.hex(0x00f51d32)
var MODULATE_BAD = Color.hex(0xf4000232)

func _ready() -> void:
	SignalBus.hex_hovered.connect(_on_hovered)
	hide()

static var selected: Hex = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var selected_hex_position := HexVector.position_to_hex(get_global_mouse_position())
	var selected_hex := GameManager.hex_grid.get_hex_at(selected_hex_position)

	_change_selected(selected_hex)

	scale = get_viewport().get_camera_2d().scale


func _change_selected(hex: Hex):
	if selected == hex:
		return

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

	var player: AnimationPlayer = hex.animation_player
	if player.is_playing() and player.current_animation != "spawn_above":
		hide()
		player.animation_finished.connect(func(_anim): show(), CONNECT_ONE_SHOT)
	else:
		show()

func _modulate_accordingly(hovered: Hex):
	if GameManager.card_holder.is_dragging_card_type(CardData.Type.PLACABLE):
		if GameManager.hex_grid.can_place_card(hovered.hex_position) \
			and hovered.type == HexData.Type.BLANK:
			sprite.modulate = MODULATE_GOOD
		else:
			sprite.modulate = MODULATE_BAD
	else:
		sprite.modulate = MODULATE_NEUTRAL
