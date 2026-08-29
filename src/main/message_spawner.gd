extends Node

const MAX_ON_SCREEN = 5
var current_on_screen = 0

var hud_message_scene: PackedScene = preload("uid://c8tblcve0no6e") 

func _ready() -> void:
	ErrorBus.hex_already_exist_on_position.connect(_handle_hex_already_exist_error)
	ErrorBus.hex_too_far_from_existing.connect(_handle_hex_too_far_error)
	ErrorBus.hex_misses_valid_path.connect(_handle_hex_misses_valid_path)
	ErrorBus.log_cursor_error.connect(_handle_log_cursor_error)

func _handle_hex_already_exist_error(_hex: HexVector):
	spawn_cursor_message("Can't place a hex on an already existing place")

func _handle_hex_too_far_error(_hex: HexVector):
	spawn_cursor_message("Can't place a hex without a non-blank neighbour")

func _handle_hex_misses_valid_path(_hex: HexVector):
	spawn_cursor_message("Hex misses valid flow path")

func _handle_log_cursor_error(s: String):
	spawn_cursor_message(s)

func _calculate_popup_duration(text: String):
	const READING_SPEED := 20.0
	const MIN_DURATION := 2.0
	var multiplier = min(float(len(text)) / READING_SPEED, 1.0)
	return MIN_DURATION * multiplier

func spawn_cursor_message(text: String):
	if current_on_screen >= MAX_ON_SCREEN:
		return

	var hud_message: HudMessage = hud_message_scene.instantiate()

	add_child(hud_message)
	hud_message.global_position = GameManager.hex_grid.get_global_mouse_position()


	hud_message.show_text(text)
	current_on_screen += 1
	await get_tree().create_timer(_calculate_popup_duration(text)).timeout
	hud_message.slide_out()
	current_on_screen -= 1
