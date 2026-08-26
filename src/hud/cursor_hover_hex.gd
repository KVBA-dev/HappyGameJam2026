extends Node2D

@onready var sprite: Sprite2D = %HexSprite.background_sprite

var MODULATE_GOOD = Color.hex(0x00ffff32)
var MODULATE_BAD = Color.hex(0xf4000232)

func _ready() -> void:
	SignalBus.hex_hovered.connect(_on_hovered)
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	scale = get_viewport().get_camera_2d().scale
	if not Hex.currently_hovered:
		hide()

func _on_hovered(hex: Hex):
	_modulate_accordingly(hex)

	global_position = Hex.currently_hovered.global_position

	var player: AnimationPlayer = Hex.currently_hovered.animation_player
	if player.is_playing() and player.current_animation != "spawn_above":
		hide()
		player.animation_finished.connect(func(_anim): show(), CONNECT_ONE_SHOT)
	else:
		show()

func _modulate_accordingly(hovered: Hex):
	if GameManager.hex_grid.can_place_card(hovered.hex_position) \
		or hovered.type != HexData.Type.BLANK:
		sprite.modulate = MODULATE_GOOD
	else:
		sprite.modulate = MODULATE_BAD
